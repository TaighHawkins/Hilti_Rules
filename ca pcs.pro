%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CA PCS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ca_pcs, `23 February 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_user_field( invoice, delivery_id, `Delivery ID` ).

i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).

i_user_field( line, allan_extra_item, `Allan extra item` ).
bespoke_e1edp19_segment( [ `098`, allan_extra_item ] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	---	9th July
%
%	-	Revamped the shipping instructions or statement - now uses a lookup
%		which sets a flag allowing for any number of combinations of names to be used
%
%	---	10th July
%
%	-	Added conditional item search - will attempt to pull the item code
%		from the description
%		
%	---	5th August
%		
%	-	Added Rocanville as an active customer dept	
%		
%	---	19th August	
%		
%	-	Updated line item capture	
%	
%	---	9th December	
%		
%	-	Added fixed street info for Cory and Allan
%	-	Also added the uom capture for Allan
%	
%	---	18th December	
%		
%	-	Added e1edp19 segment for particular Allan conditions.
%
%	---	30th January	
%		
%	-	Updated Allan fixed values.
%	-	Changed location that lookup is performed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, check_for_repair_order
	
	, check_for_revision
	
	, get_shipping_information

	, get_delivery_location

	, get_order_date
	
	, get_order_number
	
	, get_buyer_and_delivery_contact_details

	, get_lines

	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `CA-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`CA_ADAPTRIS`)
	, agent_code_3(`6800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, type_of_supply( `NC` )
	, some_variable( `Hello` )
	
	, set( no_uom_transform )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REPAIR ORDER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_repair_order, [ q0n(line), line_header_line, q(0,30,line), line_repair_line ] ).
%=======================================================================
i_line_rule( line_repair_line, [
%=======================================================================

	q0n(anything), or( [ `Repair`, `AMS` ] )

	, delivery_note_reference( `repair_order` )
	
	, trace( [ `Repair Order` ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK FOR REVISION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_revision, [
%=======================================================================

	header_line
	
	, reference_line

] ).

%=======================================================================
i_line_rule( header_line, [
%=======================================================================

	`PURCHASE`, `ORDER`, `REVISION`

] ).

%=======================================================================
i_line_rule( reference_line, [
%=======================================================================

	dummy(w), tab, peek_fails(`0`), dummy(d), newline
	
	, delivery_note_reference(`revision`)
	
	, trace( [ `delivery note reference`, delivery_note_reference ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [
%=======================================================================

	peek_fails( test( division, patience_lake ) )
	, peek_fails( test( division, allan ) )
	
	, q(0,10,line)
	
	, delivery_start_line
	
	, or( [ [ with( delivery_party ), line ], [ without( delivery_party ), delivery_party_line( 1, 0, 500 ) ] ] )
	
	, or( [ [ with( delivery_street ), q(0,2,line) ], [ without( delivery_street ), delivery_street_line( 1, 0, 500 ) ] ] )
	
	, q01( line ), delivery_city_state_and_postcode_line( 1, 0, 500 )

] ).

%=======================================================================
i_line_rule( delivery_start_line, [
%=======================================================================

	q0n(anything)
	
	, `SHIP`, `TO`, `:`, newline

] ).

%=======================================================================
i_line_rule( delivery_party_line, [
%=======================================================================

	generic_item( [ delivery_party, s1, newline ] )

] ).

%=======================================================================
i_line_rule( delivery_street_line, [
%=======================================================================

	generic_item( [ delivery_street, s1, newline ] )

] ).

%=======================================================================
i_line_rule( delivery_city_state_and_postcode_line, [
%=======================================================================

	generic_item( [ delivery_city, sf, `,` ] )
	
	, or( [ [ test( division, rocanville ), generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] ) ]
	
		, [ generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] )
	
			, generic_item( [ delivery_postcode, s1, newline ] )
			, check( delivery_postcode = PC )
			, check( q_regexp_match( `^\\D\\d\\D.\\d\\D\\d$`, PC, _ ) )			
		]
		
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET SHIPPING INFORMATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_information, [
%=======================================================================

	q(0,10,line)
	
	, shipping_start_line
	
	, peek_ahead( gen_count_lines( [ shipping_end_line, Count ] ) )
	
	, shipping_information_line( Count, 0, 500 )

] ).

%=======================================================================
i_line_rule_cut( shipping_start_line, [ q0n(anything), `BILL`, `TO`, `:`, newline ] ).
%=======================================================================
i_line_rule_cut( shipping_end_line, [ `PO`, `Date` ] ).
%=======================================================================

%=======================================================================
i_line_rule( shipping_information_line, [
%=======================================================================

	generic_item( [ shipping_info, s1 ] )
	
	, check( i_user_check( get_shipping_information, shipping_info, Flag, ToS, CC, COR, BCFL, Test, Live ) )
	
	, trace( [ `Flag`, Flag ] )
	
	, set( division, Flag )
	
	, type_of_supply( ToS )
	
	, cost_centre( CC )
	
	, contract_order_reference( COR )
	
	, buyers_code_for_location( BCFL )
	
	, or( [ [ test(test_flag), suppliers_code_for_buyer( Test ) ]    %TEST
	
		, suppliers_code_for_buyer( Live )                    		 %PROD
		
	] )
	
	, q10( [ 
	
		or( [ [ test( division, lanigan )
	
				, picking_instructions(`DHL ACCOUNT# 778779`)
				, shipping_instructions(`DHL ACCOUNT# 778779     ~Note Receiving Hours 8AM to 3PM Mon-Fri`)
			
			]
			
			, [ test( division, patience_lake )
			
				, delivery_party( `P C S POTASH PATIENCE LAKE` )	
				, delivery_street( `HWY 316 16 KM EAST` )		
				, delivery_city( `SASKATOON` )		
				, delivery_postcode( `S7K 3L6` )			
				, delivery_state( `SK` )
				
			]
			
			, [ test( division, rocanville )	
			
				, delivery_street( `16 KM NORTH OF ROCANVILLE` )	
				, delivery_postcode( `S0A 3L0` )
				
			]

			, [ test( division, allan )	
			
				, delivery_party( `P C S LTD ALLAN DIV` )	
				, delivery_street( `4 KM NORTH OF ALLAN ON HWY 397` )
				, delivery_city( `ALLAN` )
				, delivery_postcode( `S0K 0C0` )
				, delivery_state( `SK` )
				
			]
		
			, [ test( division, cory )	
			
				, delivery_party( `PCS CORY DIVISION` )	
				, delivery_street( `Highway #7 West` )
				
			]
			
		] )
			
	] )

] ).

%=======================================================================
i_user_check( get_shipping_information, Shipping, Flag, ToS, CC, COR, BCFL, Test, Live ):-
%=======================================================================

	string_to_upper( Shipping, Shipping_U )
	, pcs_shipping_lookup( Shipping_Key, ToS, CC, COR, BCFL, Test, Live )
	, q_sys_sub_string( Shipping_U, _, _, Shipping_Key )
	, string_to_lower( Shipping_Key, Shipping_Key_L )
	, string_string_replace( Shipping_Key_L, ` `, `_`, Flag )
.


pcs_shipping_lookup( `CORY`			, `01`, `Standard`			, `CPT`, `SASKATOON`			, `11232639`, `10687031` ).
pcs_shipping_lookup( `ROCANVILLE`	, `01`, `Standard`			, `CPT`, `ROCANVILLE`			, `11232650`, `10685515` ).
pcs_shipping_lookup( `LANIGAN`		, `N4`, `HNA - Cust Acct`	, `EXW`, `DHL ACCOUNT# 778779`	, `11240926`, `10687560` ).
pcs_shipping_lookup( `ALLAN`		, `01`, `Standard`			, `CIP`, `ALLAN`				, `10453563`, `10685893` ).
pcs_shipping_lookup( `NEW BRUNSWICK`, `01`, `Standard`			, `CIP`, `SUSSEX`				, `10685950`, `10685950` ).
pcs_shipping_lookup( `PATIENCE LAKE`, `01`, `Standard`			, `CIP`, `DESTINATION`			, `15895680`, `15895680` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	q0n(line)
	
	, generic_vertical_details( [ [ `PO`, `DATE`, tab ], `PO`, end, invoice_date, date, none ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q(0,3,line)
	
	, generic_vertical_details( [ [ `PURCHASE`, `ORDER` ], `PURCHASE`, end, order_number, s1, tab ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_and_delivery_contact_details, [ 
%=======================================================================

	q0n(line)
	
	, buyer_header_line
	
	, buyer_contact_line
	
	, check( buyer_contact = Contact ), delivery_contact(Contact)
	
	, buyer_email_line
	
	, check( buyer_email = Email ), delivery_email(Email)
	
	, q10( [ buyer_ddi_line
	
		, check( buyer_ddi = DDI ), delivery_ddi(DDI)
	
	] )

] ).

%=======================================================================
i_line_rule( buyer_header_line, [
%=======================================================================

	q0n(anything)
	
	, read_ahead(`BUYER`), buyer_hook(w)
	
	, newline

] ).

%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	nearest( buyer_hook(start), 10, 20 )
	
	, read_ahead( [ q0n(word), `,`, buyer_contact(s1), newline ] )
	
	, append( buyer_contact(sf), ` `, `` ), `,`
	
	, trace( [ `buyer contact`, buyer_contact ] )

] ).

%=======================================================================
i_line_rule( buyer_email_line, [ 
%=======================================================================

	nearest( buyer_hook(start), 10, 20 )
	
	, generic_item( [ buyer_email, s1, newline ] )

] ).

%=======================================================================
i_line_rule( buyer_ddi_line, [
%=======================================================================

	nearest( buyer_hook(start), 10, 20 )
	
	, `Tel`, `:`
	
	, generic_item( [ buyer_ddi, s1, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_lines, first_one_only ).
%=======================================================================
i_section_end( get_lines, line_end_section_line ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ `Terms`, `and` ] ).
%=======================================================================
i_section( get_lines, [
%=======================================================================

	line_header_line

	, q0n( [

		or( [  line_invoice_rule
			
			, line

		] )
		
	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`LINE`, tab, `ITEM`, `NO`, `/`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`PO`, `TOTAL`

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, peek_ahead( gen_count_lines( [ or( [ line_end_line, line_date_line, generic_line( [ [ `Ship`, `To` ] ] ), manufacturer_line ] ), Count ] ) )
	
	, or( [ [ check( Count > 0 ), line_descr_line( Count ) ]
	
		, [ check( Count = 0 ), set( need_descr ) ]
		
	] )
	
	, q0n(line), peek_ahead( or( [ line_end_line, line_date_line, manufacturer_line ] ) )
	
	, or( [ test( got_item )
	
		, [ test( need_descr )
			, generic_horizontal_details( [ [ at_start, `Supplier`, `Item`, `:` ], line_item, [ begin, q(dec,4,10), end ] ] )
			, generic_line( [ generic_item( [ line_descr, s1, newline ] ) ] )
		]
		
		, or( [ [  manufacturer_line
	
				, line_item_line
				
			]
			
			, line_item( `Missing` )
			
		] )
		
	] )
	
	, q10( [ test( allan_extra_item_line )
		, check( line_item = Item )
		, allan_extra_item( Item )
		, trace( [ `Extra item populated` ] )
	] )
	
	, clear( got_item )
	, clear( allan_extra_item_line )
	, clear( need_descr )

] ).

%=======================================================================
i_line_rule_cut( line_date_line, [ q0n(anything), dummy(f( [ q(dec,2,2) ] ) ), `-`, dumm( f( [ q(alpha,3,3) ] ) ), `-`, dum(f( [ q(dec,4,4) ] ) ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	generic_item( [ line_order_line_number, d, tab ] )
	
	, q10( generic_item( [ line_item_for_buyer, s1, tab ] ) )
	
	, dummy(f( [ q(dec,2,2) ] ) ), `-`, dumm( f( [ q(alpha,3,3) ] ) ), `-`, dum(f( [ q(dec,4,4) ] ) ), tab
	
	, generic_item( [ line_quantity, d ] )

	, or( [ [ test( division, allan ), `Each`, q10( dummy(s1) ), tab
			, line_quantity_uom_code( `PC` )
			, trace( [ `Allan extra line` ] )
			, set( allan_extra_item_line )
		]
		
		, [ dummy(s1), tab ]
		
	] )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================
   
	  generic_item( [ line_descr_x, s1 ] )
	
	, or( [ [ check( i_user_check( look_for_item_in_description, line_descr_x, Descr, Item ) )
			
			, line_item( Item )
			
			, trace( [ `Item found in description`, line_item ] )
			
			, set( got_item )
			
		]
		
		, check( line_descr_x = Descr )
		
	] )
	
	, line_descr( Descr )
	
	, trace( [ `Actual line description`, line_descr ] )
	
] ).

%=======================================================================
i_line_rule_cut( manufacturer_line, [
%=======================================================================
   
	or( [ [ `Manufacturer`, `Name`, tab ]
	
		, [ `Supplier`, `Item` ]
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================
   
	dummy(d), tab
	
	, `Hilti`, tab
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
	
] ).

%=======================================================================
i_user_check( look_for_item_in_description, Descr_In, Descr, Item ):-
%=======================================================================
   
	string_string_replace( Descr_In, `ITEM`, ` ITEM`, Descr_1 ),
	string_string_replace( Descr_1, `#`, ` # `, Descr_2 ),
	string_string_replace( Descr_2, `Item`, ` Item`, Descr_3 ),
	sys_string_split( Descr_3, ` `, Descr_Split ),
	trace( split( Descr_Split ) ),
	
	( q_sys_member( Item_Word, [ `ITEM`, `Item` ] ), sys_append( Descr_List, [ Item_Word, `#`, Item | [ ] ], Descr_Split )
		
		;	sys_append( Descr_List, [ `Item`, `Number`, `#`, Item | [ ] ], Descr_Split )
		
		;	sys_append( Descr_List, [ `Hilti`, `part`, `#`, Item | [ ] ], Descr_Split )
		
		;	sys_append( [ `P/N`, Item ], Descr_List, Descr_Split )
	)
	, sys_stringlist_concat( Descr_List, ` `, Descr )	
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	qn0(line)
	
	, generic_horizontal_details( [ [ `PO`, `TOTAL`, `:`, read_ahead( total_net(d) ) ], total_invoice, d, newline ] )
	
] ).


%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).