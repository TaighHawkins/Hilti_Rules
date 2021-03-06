%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US CLEMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_clement, `11 April 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
% I USER FIELDS
%=======================================================================

i_user_field( line, potential_quantity, `potential quantity` ).
i_user_field( line, box_quantity, `box quantity` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_delivery_address

	, get_buyer_contact
	
	, get_emails
	
	, get_buyer_ddi

	, get_order_date
	
	, get_order_number

	, get_invoice_lines
	
	, or( [ get_shipping_condition, get_new_shipping_condition ] )

	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `US-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11242713` ) ]    %TEST
	    , suppliers_code_for_buyer( `19229110` )                      %PROD
	]) ]

	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, delivery_party( `CLEMENT SUPPORT SERVICES INC` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING CONDITION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_condition, [ 
%=======================================================================

	  qn0(line)
	  
	, or( [ shipping_condition_one
	
			, shipping_condition_two
			
	] )
	  
] ).

%=======================================================================
i_line_rule( shipping_condition_one, [ 
%=======================================================================

	  `Comments`, `:`, q10( tab(300) )
	  
	, peek_fails( `TOTAL` )
	  
	, shipping_condition_rule
	
] ).

%=======================================================================
i_rule( shipping_condition_rule, [ 
%=======================================================================

	  q10( [ read_ahead( [ q0n(word)
	
								, `Will`
								
								, q0n(word)
								
								, `Call`
								
								, type_of_supply( `04` )
								
								, cost_centre( `Collection _Cust` )
	
				] )
			
	] )
				
	, shipping_instructions(s1), gen_eof
	
	, trace( [ `shipping instructions`, shipping_instructions ] )	
	
] ).

%=======================================================================
i_rule( shipping_condition_two, [ 
%=======================================================================

	  shipping_condition_header
	  
	, shipping_condition_line
	
] ).

%=======================================================================
i_line_rule( shipping_condition_header, [ 
%=======================================================================

	  `Comments`, `:`
	  
] ).

%=======================================================================
i_line_rule( shipping_condition_line, [ 
%=======================================================================

	  peek_fails( [ `PLEASE`, `CONFIRM`, `PRICING`, `AND`, `LEAD`, `TIME` ] )
	  
	, shipping_condition_rule
	  
] ).

%=======================================================================
i_rule( get_new_shipping_condition, [ 
%=======================================================================

	  q(0,10,line), new_shipping_condition_header_line
	  
	, new_shipping_condition_line
	  
] ).

%=======================================================================
i_line_rule( new_shipping_condition_header_line, [ `Our`, `Cust`, `No`, tab ] ).
%=======================================================================
i_line_rule( new_shipping_condition_line, [ 
%=======================================================================

	  q01( [ dummy(s1), tab ] )
	  
	, `Will`, `Call`
	
	, type_of_supply( `04` )
	
	, cost_centre( `Collection _Cust` )
	  
	, trace( [ `shipping condition found` ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q0n(line), delivery_header_line( [ LEFT ] )
	  
	, delivery_street_line( 1, LEFT, 500 )
	  
	, delivery_city_state_postcode_line( 1, LEFT, 500 )
	  
] ).

%=======================================================================
i_line_rule( delivery_header_line( [ LEFT ] ), [ 
%=======================================================================

	  q0n(anything)
	  
	, `SHIP`, read_ahead( `TO` ), hook(w)
	
	, check( i_user_check( gen_same, hook(end), LEFT ) )
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	  delivery_street(s1), newline
	
	, trace( [ `delivery street`, delivery_street ] )
	
] ).

%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [ 
%=======================================================================

	  read_ahead( [ delivery_dept(sf), `,` ] )
	  
	, delivery_city(sf), `,`
	
	, delivery_state(f( [ begin, q(alpha,2,2), end ] ) )
	
	, delivery_postcode(f( [ begin, q(dec,5,5), end ] ) )
	
	, q10( append( delivery_postcode(f( [ begin, q(other("-"),1,1), q(dec,4,4), end ] ) ), ``, `` ) )
	
	, newline
	
	, trace( [ `other delivery stuffs`, delivery_postcode, delivery_city, delivery_state ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * CONTACT DETAILS * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,7,line), vertical_invoice_details( [ [ `PO`, `#`, tab ], `PO`, end, order_number, s1, tab ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  qn0(line), horizontal_invoice_details( [ [ `Authorized` ], signature, s1, gen_eof ] )
	  
	, q01(line), horizontal_invoice_details( [ buyer_contact, s1, gen_eof ] )
	
	, check( buyer_contact(start) > signature(end) )
	
	, peek_fails( [ check( q_sys_member( buyer_contact, [ `Approved` ] ) ) ] )
	
	, check( i_user_check( gen_same, buyer_contact, CONTACT ) )
	
	, delivery_contact( CONTACT )
	 
] ).

%=======================================================================
i_rule( get_emails, [ 
%=======================================================================

	  buyer_email( FROM )
	
	, delivery_email( FROM )
	
	, trace( [ `emails`, buyer_email ] )
	 
] )
:-
	i_mail( from, FROM )
.

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,5,line), horizontal_invoice_details( [ [ `Phone`, `-` ], buyer_ddi, s1, gen_eof ] )
	  
	, check( i_user_check( gen_same, buyer_ddi, DDI ) )
	
	, delivery_ddi( DDI )
	 
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,7,line), vertical_invoice_details( [ [ `Rev`, tab, `Date`, tab ], `Date`, start, invoice_date, date, gen_eof ] )
	  
] ).

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line)
	  
	, read_ahead( horizontal_invoice_details( [ [ `TOTAL` ], 200, total_net, d, newline ] ) )
	  
	, horizontal_invoice_details( [ [ `TOTAL` ], 200, total_invoice, d, newline ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_section_control( get_invoice_lines, first_one_only ).

i_section_end( get_invoice_lines, line_end_section_line ).

%=======================================================================
i_line_rule_cut( line_end_section_line, [ `Created`, `On` ] ).
%=======================================================================

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, qn0( [ peek_fails(line_end_line)

		, or( [  line_invoice_rule
			
				, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Ln`,`#`, tab, `Ordered` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Comments`, `:`, tab ] ).
%=======================================================================

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, q10( read_ahead( line_box_rule ) )
	  
	, get_description_rule
	
	, or( [ test( first_line )
	
		, [ peek_fails( test( first_line ) )
			
			, or( [  hilti_item_rule
	
				, vendor_item_rule
			
				, hash_item_rule
			
				, [ trace( [ `missing` ] ), line_item( `Missing` ), set( missing ) ]
				
			] )
			
		]
			
	] )
	
	, get_final_description_rule
	
	, trace( [ `total descr`, line_descr ] )
	
	, quantity_adjustment_rule
	
	, clear( missing ), clear( first_line )

] ).

%=======================================================================
i_rule( get_description_rule, [
%=======================================================================

	  q(0,2, [ append_descr_line, peek_fails( or( [ line_check_line, line_end_line ] ) ) ] )

] ).

%=======================================================================
i_rule_cut( get_final_description_rule, [
%=======================================================================

	  q(2,0, append_descr_line ), read_ahead( or( [ line_check_line, line_end_line ] ) )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  invoice_item( [ line_order_line_number, d, tab ] )
	  
	, invoice_item( [ potential_quantity, d, tab ] )
	
	, invoice_item( [ balance, d, `q10`, tab ] )
	
	, or( [ [ line_item( f( [ q(alpha("HILT"),3,5), begin, q(dec,4,9), end ] ) ), tab, set( first_line )
	
			, trace( [ `got item from first line` ] )
			
		]
		
		, invoice_item( [ line_descr, s1, tab ] )
		
	] )
	
	, invoice_item( [ line_unit_amount_x, w, tab ] )
		
	, invoice_item( [ line_net_amount, d, tab ] )
	
	, invoice_item( [ line_original_order_date, date, `q01`, tab ] )
	
	, invoice_item( [ promise_date, s1, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_check_line, [
%=======================================================================

	  num(d), tab
	  
	, num(d), tab
	
	, num(d)
	
	, trace( [ `Found a line`  ] )
	
] ).

%=======================================================================
i_line_rule( append_descr_line, [
%=======================================================================

	  append( line_descr(s1), `~`, `` ), q01( [ tab, `ASAP` ] ), newline
	  
	, trace( [ `appended` ] )
	
] ).

%=======================================================================
i_rule_cut( line_box_rule, [
%=======================================================================

	  trace( [ `looking for a box line` ] )
	  
	, q(0,3, line ), peek_fails( or( [ line_check_line, line_end_line ] ) )
	
	, line_box_line

] ).

%=======================================================================
i_line_rule( line_box_line, [
%=======================================================================

	  q0n(word)
	  
	, or( [ [ box_quantity(d)
	
					, q10( or( [ `/`, `PER` ] ) )
					
					, `BOX`
					
				]
				
				, [ `BOX`
	
					, q10( or( [ `/`, `PER` ] ) )
					
					, box_quantity(d)
					
				]
	] )
	
	, set( box )
	
	, trace( [ `box`, box_quantity ] )
	
] ).

%=======================================================================
i_rule_cut( hilti_item_rule, [
%=======================================================================

	  trace( [ `looking for a hilti item` ] )
	  
	, get_description_rule
	 
	, read_ahead( append_descr_line ), hilti_item_line
	
] ).

%=======================================================================
i_line_rule_cut( hilti_item_line, [
%=======================================================================

	  q0n(word)
	  
	, `HILTI`,`#`
	
	, q10( `:` )
	
	, line_item(fd( [ begin, q(dec,4,9), end ] ) )
	
	, trace( [ `hilti item`, line_item ] )
	
] ).

%=======================================================================
i_rule_cut( vendor_item_rule, [
%=======================================================================

	  trace( [ `looking for a vendor item` ] )
	  
	, get_description_rule
	 
	, read_ahead( append_descr_line ), vendor_item_line
	
] ).

%=======================================================================
i_line_rule_cut( vendor_item_line, [
%=======================================================================

	  q0n(word)
	  
	, `Vendor`, q10( `Item` )
	
	, q10( `#` )
	
	, q10( `:` )
	
	, line_item(fd( [ begin, q(dec,4,9), end ] ) ), newline
	
	, trace( [ `vendor item`, line_item ] )
	
] ).

%=======================================================================
i_rule_cut( hash_item_rule, [
%=======================================================================

	  trace( [ `looking for a hash item` ] )
	  
	, get_description_rule
	 
	, read_ahead( append_descr_line ), hash_item_line
	
] ).

%=======================================================================
i_line_rule_cut( hash_item_line, [
%=======================================================================

	  q0n(word)
	  
	, `#`
	
	, line_item(fd( [ begin, q(dec,4,9), end ] ) ), newline
	
	, trace( [ `hash item`, line_item ] )
	
] ).

%=======================================================================
i_rule_cut( quantity_adjustment_rule, [
%=======================================================================

	  or( [ line_item_adjustment_rule
	  
			, box_adjustment_rule
			
			, no_adjustment_rule
	
	] )
	
	, clear( box )
	
] ).

%=======================================================================
i_rule( line_item_adjustment_rule, [
%=======================================================================

	  peek_fails( test( missing ) )
	  
	, check( i_user_check( check_the_quantity, line_item, PACK, UOM ) )
	
	, trace( [ `looked up`, PACK, UOM ] )
	
	, the_calculation_rule( [ PACK, NEW_ROUND ] )
	
	, line_quantity( NEW_ROUND )
	
	, line_quantity_uom_code_x( UOM )
	
	, trace( [ `item lookup`, line_quantity, line_quantity_uom_code_x ] )
	
] ).

%=======================================================================
i_rule( box_adjustment_rule, [
%=======================================================================

	  test( box )
	  
	, check( i_user_check( gen_same, box_quantity, PACK ) )
	
	, trace( [ `looked up`, PACK ] )
	
	, the_calculation_rule( [ PACK, NEW_ROUND ] )
	
	, line_quantity( NEW_ROUND )
	
	, line_quantity_uom_code_x( `BOX` )
	
	, trace( [ `box adjustment`, line_quantity ] )
	
] ).

%=======================================================================
i_rule( no_adjustment_rule, [
%=======================================================================

	  check( i_user_check( gen_same, potential_quantity, QTY ) )
	
	, line_quantity( QTY )

	, trace( [ `no adjustment`, line_quantity ] )
	
] ).

%=======================================================================
i_rule( the_calculation_rule( [ PACK, NEW_ROUND ] ), [
%=======================================================================  
	
	  check( sys_calculate_str_divide( potential_quantity, PACK, NEW_QTY ) )
	
	, trace( [ `divided`, NEW_QTY ] )
	
	, check( sys_calculate_str_add( NEW_QTY, `0.4999`, NEW_CHEAT ) )
	
	, trace( [ `cheated`, NEW_CHEAT ] )
	
	, check( sys_calculate_str_round_0( NEW_CHEAT, NEW_ROUND ) )
	
	, trace( [ `rounded`, NEW_ROUND ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE ITEM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( invoice_item( [ VARIABLE, PARAMETER, SPACING ] ), [ invoice_item_rule( [ VARIABLE, PARAMETER, `not`, SPACING ] ) ] ).
%=======================================================================
i_rule( invoice_item( [ VARIABLE, PARAMETER, OPTIONAL, SPACING ] ), [ invoice_item_rule( [ VARIABLE, PARAMETER, OPTIONAL, SPACING ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( invoice_item_rule( [ VARIABLE, PARAMETER, OPTIONAL, SPACING ] ), [ 
%=======================================================================

	  q10( [ check( q_sys_member( PARAMETER, [ `d` ] ) )
	  
				, q10( `$` )
	
		] )
		
	, READ_VARIABLE
			
	, q10( [ check( q_sys_member( VARIABLE_NAME, [ `line_descr` ] ) )
	  
			, check( q_sys_member( SPACING_STRING, [ `newline` ] ) )
			
			, q01( [ tab, READ_MORE_VARIABLE ] )
				
		] )
		
	, or( [ [ check( q_sys_member( SPACING_STRING, [ `none` ] ) ) ]
	
			, [ check( q_sys_sub_string( OPTIONAL, _, _, `not` ) )
	
				, SPACING
			
			]
			
			, [ check( q_sys_member( OPTIONAL, [ `q10` ] ) )
	
				, q10( SPACING )
			
			]
			
			, [ check( q_sys_member( OPTIONAL, [ `q01` ] ) )
	
				, q01( SPACING )
			
			]
		
		] )
	
	, trace( [ VARIABLE_NAME, VARIABLE ] )
	
] )
:-
	  READ_VARIABLE=.. [ VARIABLE, PARAMETER ]
	
	, READ_MORE_VARIABLE =.. [ append, READ_VARIABLE, ` `, `` ]
	
	, sys_string_atom( VARIABLE_NAME, VARIABLE )
	
	, sys_string_atom( SPACING_STRING, SPACING )
	
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HORIZONTAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( horizontal_invoice_details( [ VARIABLE, PARAMETER, AFTER ] ), [ horizontal_details( [ `nothin`, 100, VARIABLE, PARAMETER, AFTER ] ) ] ).
%=======================================================================
i_line_rule( horizontal_invoice_details( [ SEARCH, VARIABLE, PARAMETER, AFTER ] ), [ horizontal_details( [ SEARCH, 100, VARIABLE, PARAMETER, AFTER ] ) ] ).
%=======================================================================
i_line_rule( horizontal_invoice_details( [ SEARCH, TAB_LENGTH, VARIABLE, PARAMETER, AFTER ] ), [ horizontal_details( [ SEARCH, TAB_LENGTH, VARIABLE, PARAMETER, AFTER ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( horizontal_details( [ SEARCH, TAB_LENGTH, VARIABLE, PARAMETER, AFTER ] ), [
%=======================================================================

	  q0n(anything)
	
	, or( [ [ check( q_sys_member( SEARCH, [ `nothin` ] ) ) ]
	
			, SEARCH
	  
	] )
	
	, q10( or( [ `:`, `-`, `;`, `.` ] ) )
	
	, q10( tab( TAB_LENGTH ) )
	  
	, READ_VARIABLE
	
	, or( [ check( q_sys_member( AFTER_STRING, [ `none` ] ) )
	
			, AFTER
			
		] )
	
	, trace( [ VARIABLE_NAME, VARIABLE ] )

] )
:-

	  READ_VARIABLE=.. [ VARIABLE, PARAMETER ]
	
	, sys_string_atom( VARIABLE_NAME, VARIABLE )
	
	, sys_string_atom( AFTER_STRING, AFTER )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VERTICAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( vertical_invoice_details( [ SEARCH, ANCHOR, POS, VARIABLE, PARAM, AFTER ] ), [
%=======================================================================

	  vertical_invoice_details( [ SEARCH, ANCHOR, POS, 10, 10, VARIABLE, PARAM, AFTER ] )

] ).

%=======================================================================
i_rule( vertical_invoice_details( [ SEARCH, ANCHOR, POS, LEFT, RIGHT, VARIABLE, PARAM, AFTER ] ), [
%=======================================================================

	  look_for_anchor( [ SEARCH, ANCHOR ] ) 
	  
	, q01(line), look_for_detail( [ POS, LEFT, RIGHT, VARIABLE, PARAM, AFTER ] )

] ).

%=======================================================================
i_line_rule( look_for_anchor( [ SEARCH, ANCHOR ] ), [
%=======================================================================

	  q0n(anything)
	  
	, read_ahead( SEARCH )
	
	, q0n(anything), read_ahead( ANCHOR )
	
	, anchor(w)

] ).

%=======================================================================
i_line_rule( look_for_detail( [ POS, LEFT, RIGHT, VARIABLE, PARAM, AFTER ] ), [
%=======================================================================

	  nearest( anchor(POS), LEFT, RIGHT )
	  
	, READ_VARIABLE
	
	, or( [ check( q_sys_member( AFTER_STRING, [ `none` ] ) )
	
			, AFTER
	
			, [ check( q_sys_member( AFTER, [ `q10( tab )` ] ) ), q10( tab ) ]
			
			, [ check( q_sys_member( AFTER, [ `q01( tab )` ] ) ), q01( tab ) ]
			
		] )
		
	, trace( [ VARIABLE_NAME, VARIABLE ] )

] )
:-
	  READ_VARIABLE =.. [ VARIABLE, PARAM ]
	
	, sys_string_atom( VARIABLE_NAME, VARIABLE )
	
	, sys_string_atom( AFTER_STRING, AFTER )
.


i_op_param( orders05_idocs_first_and_last_name( buyer_contact, NAME1, `CLEMENT SUPPORT SERVICES INC` ), _, _, _, _) :- result( _, invoice, buyer_contact, NU ), string_to_upper(NU, NAME1).

i_op_param( orders05_idocs_first_and_last_name( delivery_contact, NAME2, `CLEMENT SUPPORT SERVICES INC` ), _, _, _, _) :- result( _, invoice, delivery_contact, NU2 ), string_to_upper(NU2, NAME2).



%=======================================================================
%  lookup
%=======================================================================

i_user_check( check_the_quantity, ITEM, PACK, UOM )
:-
	item_to_quantity_lookup( ITEM, PACK, UOM )
.

item_to_quantity_lookup( `LINE ITEM`, `PACKAGE SIZE`, `ZPX` ).
item_to_quantity_lookup( `47947`, `10`, `ZPX` ).
item_to_quantity_lookup( `50107`, `100`, `BOX` ).
item_to_quantity_lookup( `50108`, `100`, `BOX` ).
item_to_quantity_lookup( `50352`, `100`, `BOX` ).
item_to_quantity_lookup( `50353`, `100`, `BOX` ).
item_to_quantity_lookup( `50372`, `1000`, `BOX` ).
item_to_quantity_lookup( `50373`, `1000`, `BOX` ).
item_to_quantity_lookup( `60579`, `1`, `EA` ).
item_to_quantity_lookup( `63856`, `1`, `EA` ).
item_to_quantity_lookup( `205989`, `5`, `ZPX` ).
item_to_quantity_lookup( `205990`, `5`, `ZPX` ).
item_to_quantity_lookup( `205991`, `5`, `ZPX` ).
item_to_quantity_lookup( `229138`, `1`, `EA` ).
item_to_quantity_lookup( `230567`, `100`, `BOX` ).
item_to_quantity_lookup( `237371`, `100`, `BOX` ).
item_to_quantity_lookup( `241382`, `1`, `EA` ).
item_to_quantity_lookup( `241383`, `20`, `BOX` ).
item_to_quantity_lookup( `249702`, `100`, `BOX` ).
item_to_quantity_lookup( `253242`, `50`, `BOX` ).
item_to_quantity_lookup( `253784`, `1`, `EA` ).
item_to_quantity_lookup( `259579`, `1`, `EA` ).
item_to_quantity_lookup( `259580`, `1`, `EA` ).
item_to_quantity_lookup( `273210`, `1`, `EA` ).
item_to_quantity_lookup( `273211`, `1`, `EA` ).
item_to_quantity_lookup( `273662`, `20`, `ZPX` ).
item_to_quantity_lookup( `282503`, `100`, `BOX` ).
item_to_quantity_lookup( `282504`, `100`, `BOX` ).
item_to_quantity_lookup( `282509`, `25`, `BOX` ).
item_to_quantity_lookup( `282513`, `15`, `BOX` ).
item_to_quantity_lookup( `282522`, `50`, `BOX` ).
item_to_quantity_lookup( `282523`, `50`, `BOX` ).
item_to_quantity_lookup( `282524`, `50`, `BOX` ).
item_to_quantity_lookup( `282526`, `25`, `BOX` ).
item_to_quantity_lookup( `282527`, `25`, `BOX` ).
item_to_quantity_lookup( `282528`, `25`, `BOX` ).
item_to_quantity_lookup( `282529`, `25`, `BOX` ).
item_to_quantity_lookup( `282530`, `15`, `BOX` ).
item_to_quantity_lookup( `282535`, `10`, `BOX` ).
item_to_quantity_lookup( `282540`, `100`, `BOX` ).
item_to_quantity_lookup( `282554`, `50`, `BOX` ).
item_to_quantity_lookup( `282556`, `50`, `BOX` ).
item_to_quantity_lookup( `282559`, `25`, `BOX` ).
item_to_quantity_lookup( `282567`, `50`, `BOX` ).
item_to_quantity_lookup( `282569`, `25`, `BOX` ).
item_to_quantity_lookup( `282571`, `25`, `BOX` ).
item_to_quantity_lookup( `283209`, `1`, `EA` ).
item_to_quantity_lookup( `283548`, `1`, `EA` ).
item_to_quantity_lookup( `286021`, `20`, `BOX` ).
item_to_quantity_lookup( `286035`, `10`, `BOX` ).
item_to_quantity_lookup( `304326`, `1`, `EA` ).
item_to_quantity_lookup( `304328`, `1`, `EA` ).
item_to_quantity_lookup( `314268`, `1`, `EA` ).
item_to_quantity_lookup( `336427`, `50`, `BOX` ).
item_to_quantity_lookup( `336428`, `25`, `BOX` ).
item_to_quantity_lookup( `336429`, `25`, `BOX` ).
item_to_quantity_lookup( `336430`, `100`, `BOX` ).
item_to_quantity_lookup( `336432`, `50`, `BOX` ).
item_to_quantity_lookup( `337111`, `1`, `EA` ).
item_to_quantity_lookup( `337918`, `1`, `EA` ).
item_to_quantity_lookup( `340225`, `1`, `EA` ).
item_to_quantity_lookup( `355327`, `1`, `EA` ).
item_to_quantity_lookup( `374336`, `5`, `ZPX` ).
item_to_quantity_lookup( `374337`, `5`, `ZPX` ).
item_to_quantity_lookup( `374496`, `100`, `BOX` ).
item_to_quantity_lookup( `374499`, `100`, `BOX` ).
item_to_quantity_lookup( `378083`, `25`, `BOX` ).
item_to_quantity_lookup( `378084`, `25`, `BOX` ).
item_to_quantity_lookup( `378085`, `25`, `BOX` ).
item_to_quantity_lookup( `378090`, `10`, `BOX` ).
item_to_quantity_lookup( `378091`, `10`, `BOX` ).
item_to_quantity_lookup( `383680`, `1`, `EA` ).
item_to_quantity_lookup( `385076`, `1`, `EA` ).
item_to_quantity_lookup( `385080`, `1`, `EA` ).
item_to_quantity_lookup( `385083`, `1`, `EA` ).
item_to_quantity_lookup( `385469`, `10`, `ZPX` ).
item_to_quantity_lookup( `385470`, `10`, `ZPX` ).
item_to_quantity_lookup( `385473`, `10`, `ZPX` ).
item_to_quantity_lookup( `386216`, `100`, `BOX` ).
item_to_quantity_lookup( `386222`, `100`, `BOX` ).
item_to_quantity_lookup( `387509`, `50`, `BOX` ).
item_to_quantity_lookup( `387510`, `50`, `BOX` ).
item_to_quantity_lookup( `387511`, `50`, `BOX` ).
item_to_quantity_lookup( `387512`, `20`, `BOX` ).
item_to_quantity_lookup( `387513`, `20`, `BOX` ).
item_to_quantity_lookup( `387514`, `20`, `BOX` ).
item_to_quantity_lookup( `387515`, `20`, `BOX` ).
item_to_quantity_lookup( `387516`, `15`, `BOX` ).
item_to_quantity_lookup( `387517`, `15`, `BOX` ).
item_to_quantity_lookup( `387518`, `15`, `BOX` ).
item_to_quantity_lookup( `387520`, `10`, `BOX` ).
item_to_quantity_lookup( `387521`, `10`, `BOX` ).
item_to_quantity_lookup( `387522`, `10`, `BOX` ).
item_to_quantity_lookup( `387523`, `50`, `BOX` ).
item_to_quantity_lookup( `387524`, `50`, `BOX` ).
item_to_quantity_lookup( `387525`, `50`, `BOX` ).
item_to_quantity_lookup( `387526`, `20`, `BOX` ).
item_to_quantity_lookup( `387527`, `20`, `BOX` ).
item_to_quantity_lookup( `387528`, `20`, `BOX` ).
item_to_quantity_lookup( `387529`, `20`, `BOX` ).
item_to_quantity_lookup( `387530`, `15`, `BOX` ).
item_to_quantity_lookup( `387532`, `15`, `BOX` ).
item_to_quantity_lookup( `387533`, `15`, `BOX` ).
item_to_quantity_lookup( `387534`, `10`, `BOX` ).
item_to_quantity_lookup( `387535`, `10`, `BOX` ).
item_to_quantity_lookup( `387536`, `10`, `BOX` ).
item_to_quantity_lookup( `388548`, `100`, `BOX` ).
item_to_quantity_lookup( `401234`, `100`, `BOX` ).
item_to_quantity_lookup( `409492`, `100`, `BOX` ).
item_to_quantity_lookup( `409499`, `100`, `BOX` ).
item_to_quantity_lookup( `409500`, `50`, `BOX` ).
item_to_quantity_lookup( `411731`, `50`, `BOX` ).
item_to_quantity_lookup( `411733`, `20`, `BOX` ).
item_to_quantity_lookup( `411734`, `20`, `BOX` ).
item_to_quantity_lookup( `411736`, `20`, `BOX` ).
item_to_quantity_lookup( `411739`, `15`, `BOX` ).
item_to_quantity_lookup( `411740`, `10`, `BOX` ).
item_to_quantity_lookup( `411741`, `10`, `BOX` ).
item_to_quantity_lookup( `412590`, `20`, `BOX` ).
item_to_quantity_lookup( `418040`, `100`, `BOX` ).
item_to_quantity_lookup( `418045`, `100`, `BOX` ).
item_to_quantity_lookup( `418056`, `50`, `BOX` ).
item_to_quantity_lookup( `423177`, `1`, `EA` ).
item_to_quantity_lookup( `423178`, `20`, `BOX` ).
item_to_quantity_lookup( `423253`, `4500`, `BOX` ).
item_to_quantity_lookup( `423471`, `100`, `BOX` ).
item_to_quantity_lookup( `423472`, `100`, `BOX` ).
item_to_quantity_lookup( `423473`, `100`, `BOX` ).
item_to_quantity_lookup( `424576`, `50`, `BOX` ).
item_to_quantity_lookup( `426829`, `1`, `EA` ).
item_to_quantity_lookup( `426830`, `1`, `EA` ).
item_to_quantity_lookup( `435003`, `1`, `EA` ).
item_to_quantity_lookup( `435006`, `1`, `EA` ).
item_to_quantity_lookup( `435007`, `1`, `EA` ).
item_to_quantity_lookup( `435012`, `1`, `EA` ).
item_to_quantity_lookup( `435013`, `1`, `EA` ).
item_to_quantity_lookup( `2005629`, `1`, `EA` ).
item_to_quantity_lookup( `2007057`, `1`, `EA` ).
item_to_quantity_lookup( `2022793`, `1`, `EA` ).
item_to_quantity_lookup( `2025920`, `8`, `ZPX` ).
item_to_quantity_lookup( `2034016`, `1`, `EA` ).
item_to_quantity_lookup( `2038074`, `1`, `EA` ).
item_to_quantity_lookup( `2038076`, `1`, `EA` ).
item_to_quantity_lookup( `2038078`, `1`, `EA` ).
item_to_quantity_lookup( `2045004`, `10`, `ZPX` ).
item_to_quantity_lookup( `2045010`, `10`, `ZPX` ).
item_to_quantity_lookup( `2045011`, `10`, `ZPX` ).
item_to_quantity_lookup( `2045013`, `10`, `ZPX` ).
item_to_quantity_lookup( `2045021`, `10`, `ZPX` ).
item_to_quantity_lookup( `2058129`, `50`, `BOX` ).
item_to_quantity_lookup( `3425973`, `1`, `EA` ).
item_to_quantity_lookup( `3440173`, `150`, `BOX` ).
item_to_quantity_lookup( `3452534`, `1`, `EA` ).
item_to_quantity_lookup( `3452541`, `1`, `EA` ).
item_to_quantity_lookup( `3469712`, `1`, `EA` ).
item_to_quantity_lookup( `3498241`, `1`, `EA` ).

