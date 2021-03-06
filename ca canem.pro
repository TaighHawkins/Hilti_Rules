%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CA CANEM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ca_canem, `30 July 2015` ).

i_date_format( `m/d/y` ).

i_format_postcode( X, X ).

% i_pdf_parameter( same_line, 7 ).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_job, `Delivery Job` ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( line, line_item_098, `Line Item 098` ).
bespoke_e1edp19_segment( [ `098`, line_item_098 ] ).

i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).
i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).

i_op_param( output, _, _, _, orders05_idoc_xml ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_buyers_code_for_buyer  
	
	, get_delivery_details
	, check_shipping_method

	, get_order_date
	
	, get_order_number

	, get_delivery_contact
	, get_delivery_ddi
	
	, get_buyer_dept
	, get_customer_comments
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

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

	, or( [ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, agent_name(`CA_ADAPTRIS`)
	, agent_code_3(`6800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Canem Systems Ltd.` )
	
	, set( no_uom_transform )
	, set( no_scfb )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyers_code_for_buyer, [
%=======================================================================

	q(0,30,line), generic_horizontal_details( [ [ `Canem`, `Systems` ] ] )
	
	, q(0,5,line)
	
	, generic_line( [ [ city(sf), `,`, state(f( [ begin, q(alpha,2,2), end ] ) ), q10( `,` ), q10( tab ), a_postcode(s1) ] ] )
	, trace( [ `Found line` ] )
	
	, check( i_user_check( manipulate_buyer_dept, city, BCFB ) )
	, buyers_code_for_buyer( BCFB )
	, trace( [ `BCFB`, buyers_code_for_buyer ] )
	
	, trace( [ `City`, city ] )
	
	, q10( [ check( city = `EDMONTON` )
		, set( edmonton )
		, trace( [ `Edmonton set` ] )
	] )
	
	, q10( [ check( city = `CALGARY` )
		, set( calgary )
		, trace( [ `Calgary set` ] )
	] )
	
	, q10( [ test( edmonton )
		
		, or( [ check_shipping_method
		
			, [ check( i_user_check( check_zip_is_in_lookup, a_postcode ) )
				, type_of_supply( `NN` )
				, cost_centre( `HNA:JOBSITE_NEXT_AM` )
				, trace( [ `In lookup` ] )
			]
			
			, [ type_of_supply( `01` )
				, cost_centre( `Standard` )
				, trace( [ `Default Values` ] )
			]
		] )
		, trace( [ `ToS and CC`, type_of_supply, cost_centre ] )
	] )
	
	, q10( [ peek_fails( test( edmonton ) )
		, type_of_supply( `01` )
		, cost_centre( `Standard` )
	] )
	
] ).


%=======================================================================
i_rule( check_shipping_method, [
%=======================================================================

	q(0,100,line)
	, generic_horizontal_details( [ [ `Pickup` ] ] )
	
	, type_of_supply( `04` )
	, cost_centre( `Collection_Cust` )
	
] ).


%=======================================================================
i_user_check( manipulate_buyer_dept, DeptIn, DeptOut )
%-----------------------------------------------------------------------
:- 
	strcat_list( [ `CACAN`, DeptIn ], Dept ),
	sys_string_length( Dept, DeptLen ),
	
	( DeptLen < 12
		->	Dept = DeptOut
		
		;	q_sys_sub_string( Dept, 1, 11, DeptOut )
	)
.
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY STUFF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	or( [ [ test( edmonton ), delivery_note_number( `16189696` )
			, trace( [ `Edmonton condition found - DNN populated`, delivery_note_number ] )
		]
		
		, [ q(0,20,line), generic_horizontal_details( [ [ `Page`, `:` ] ] )
			, line
			, generic_horizontal_details( [ nearest( generic_hook(start), 150, 0 ), delivery_street, s1 ] )
			, delivery_city_state_and_postcode_line
		]
	] )

] ).


%=======================================================================
i_line_rule( delivery_city_state_and_postcode_line, [
%=======================================================================

	nearest( generic_hook(start), 150, 0 )
	
	, generic_item( [ delivery_city, sf, q10( `,` ) ] )

	, q10( generic_item( [ delivery_state, w, q10( `,` ) ] ) )
	
	, generic_item( [ delivery_postcode, sf
		, [ check( delivery_postcode = PC )
			, check( q_regexp_match( `^\\D\\d\\D.\\d\\D\\d$`, PC, _ ) ) 
		]
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Attn`, `:` ] ] )
	  
	, q(0,3,line)
	
	, generic_line( [ [ generic_item( [ delivery_job, s1, tab ] ), q10( [ dummy(s1), tab ] ), generic_item( [ invoice_date, date, tab ] ) ] ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q(0,20,line)
	
	, generic_horizontal_details( [ order_number, s1, [ newline, check( order_number(start) > 300 ) ] ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	q(0,20,line)
	
	, generic_horizontal_details( [ [ `Atten` ], delivery_contact, sf, or( [ tab, `CEll` ] ) ] )

] ).

%=======================================================================
i_rule( get_delivery_ddi, [  
%=======================================================================

	q(0,20,line)
	
	, generic_horizontal_details( [ [ `Cell` ], delivery_ddi, s1 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER DEPT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_dept, [  
%=======================================================================

	check( i_user_check( manipulate_buyer_dept, Name, Dept ) )
	, buyer_dept( Dept )
	
	, or( [ [ check( FromU = `LKLEINFELER@CANEM.COM` )
			, delivery_from_contact( `CACAN_LKLEINFELDER` )
		]
		
		, [ with( invoice, delivery_contact, Con )
			, check( string_to_upper( Con, ConU ) )
			, check( i_user_check( manipulate_buyer_dept, ConU, DFC ) )
			, delivery_from_contact( DFC )
		]
	] )
	
	, trace( [ `Buyer Dept`, Dept ] )
	, trace( [ `Delivery From Contact`, DFC ] )

] ):- i_mail( from, From ), string_to_upper( From, FromU ), sys_string_split( FromU, `@`, [ Name | _ ] ).

%=======================================================================
i_user_check( manipulate_buyer_dept, DeptIn, DeptOut )
%-----------------------------------------------------------------------
:- 
	strcat_list( [ `CACAN`, DeptIn ], Dept ),
	sys_string_length( Dept, DeptLen ),
	
	( DeptLen < 12
		->	Dept = DeptOut
		
		;	q_sys_sub_string( Dept, 1, 11, DeptOut )
	)
.
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [  
%=======================================================================

	q10( [ test( calgary )
		, with( invoice, delivery_ddi, DDI )
		, with( invoice, delivery_contact, Con )
		, with( invoice, delivery_job, Job )
		
		, check( strcat_list( [ `PLEASE DELIVER TO `, Con, ` Cell 403-`, DDI, ` JOB `, Job ], Com ) )
		, customer_comments( Com )
		, trace( [ `Customer Comments`, Com ] )
	] )
	
	, q10( [ test( edmonton )
		, with( invoice, delivery_job, Job )
		, with( invoice, order_number, Ord )
		
		, check( strcat_list( [ `Job `, Job, ` PO `, Ord ], Com ) )
		, customer_comments( Com )
		, trace( [ `Customer Comments`, Com ] )
	] )
	
	, remove( delivery_ddi )
	, remove( delivery_contact )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_lines, [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [  line_invoice_rule
			
			, line

		] )
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ q0n( [ dummy(s1), tab ] ), header(date) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `*`, `*`, `*` ]
	
		, [ `Gross` ] 
		
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, or( [ line_descr_line
	
		, [ test( got_maybe ), check( maybe_item = Item )
			, line_item( Item )
			, trace( [ `Item from first line` ] )
		]
		
		, test( got_item )
		
		, line_item( `Missing` )
	] )
	
	, q10( [ check( line_quantity_uom_code = `PC` )
		, check( line_item = Item )
		, line_item_098( Item )
		, trace( [ `Populated 098 item`, Item ] )
	] )
	
	, clear( got_item )
	, clear( got_maybe )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	generic_item_cut( [ line_quantity, d, tab ] )
	
	, or( [ [ generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ] ] )
			, generic_item( [ line_descr, s1, tab ] )
			, set( got_item )
		]
		
		, [ read_ahead( [ q0n(word), `#`, generic_item_cut( [ maybe_item, [ begin, q(dec,5,10), end ] ] ) ] )
			, generic_item_cut( [ line_descr, s1, tab ] )
			, set( got_maybe )
		]
				
		, [ read_ahead( [ q0n(word), generic_item_cut( [ line_item, [ begin, q(dec,5,10), end ] ] ) ] )
			, generic_item_cut( [ line_descr, s1, tab ] )
			, set( got_item )
		]

		, generic_item_cut( [ line_descr, s1, tab ] )
	] )

	, or( [ [ `E`, tab, line_quantity_uom_code( `PC` ) ]
		, generic_item_cut( [ line_quantity_uom_code, w, tab ] )
	] )
	
	, generic_item_cut( [ line_unit_amount, d, tab ] )
	, generic_item_cut( [ line_net_amount, d, newline ] )
] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================
   
	or( [ test( got_item )
	
		, read_ahead( [ q0n(word), generic_item_cut( [ line_item, [ begin, q(dec,5,10), end ] ] ) ] )
		
		, [ test( got_maybe )
			, check( maybe_item = Item )
			, line_item( Item )
		]
		
		, line_item( `Missing` )
	] )
	
	, append( line_descr(s1), ` `, `` ), newline
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `Gross`, `:` ], 250, total_invoice, d, newline ] )
	
	, check( total_invoice = Total )
	
	, total_net( Total )	
	
	, or( [ [ with( invoice, delivery_charge, Charge )
	
			, check( sys_calculate_str_subtract( total_net, Charge, Net_1 ) )
			
			, net_subtotal_2( Charge )
			
			, gross_subtotal_2( Charge )
			
		]
		
		, [ without( delivery_charge )
		
			, check( total_net = Net_1 )
			
		]
		
	] )
	
	, net_subtotal_1( Net_1 )
	
	, gross_subtotal_1( Net_1 )
	
] ).