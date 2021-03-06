%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US WEBBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_webber, `13 July 2015` ).

i_date_format( `m/d/y` ).

i_pdf_parameter( space, 2 ).
i_pdf_parameter( same_line, 7 ).

i_format_postcode( X, X ).

i_user_field( invoice, additional_email_text, `Additional Email Text` ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ):- not( grammar_set( exclude_zed ) ).

i_op_param( xml_transform( delivery_state, In ), _, _, _, Out )
:-
	string_to_upper( In, InU ),
	InU = `TEXAS`,
	Out = `TX`
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_page_split_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  check_items
	  
	, check_flags

] ).

%=======================================================================
i_rule( check_items, [ 
%=======================================================================

	q0n(line), line_header_line
	
	, trace( [ `Got header` ] )

	, q0n(
		or( [ generic_horizontal_details( [ nearest_word( item_hook(start), 10, 10 )
				, item,  [ begin, q(alpha("DPC"),3,3), q(dec,4,10), end ]
				, set( dpc_item ) 
			] )
		
			, generic_horizontal_details( [ nearest_word( item_hook(start), 10, 10 )
				, item, [ begin, q(dec,4,10), end ]
				, set( normal_item ) 
			] )
			
			, line
		] )
	)
	, generic_line( [ [ `Exempt`, `Total` ] ] )
	, trace( [ `End` ] )

] ).
	
%=======================================================================
i_rule( check_flags, [ 
%=======================================================================

	or( [ [ test( dpc_item ), test( normal_item )
			, continuation_page( 2 )
			, check( set_imail_data( `item_type`, `both` ) )
			, trace( [ `Both items detected` ] )
		]
		
		, [ test( dpc_item )
			, continuation_page( 2 )
			, check( set_imail_data( `item_type`, `dpc` ) )
			, trace( [ `Only DPC items detected` ] )
		]
		
		, [ test( normal_item )
			, continuation_page( 1 )
			, check( set_imail_data( `item_type`, `normal` ) )
			, trace( [ `Only Normal items detected` ] )
		]
	] )

] ):- not( q_imail_data( self, `item_type`, _ ) ).
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	 
	, check_imail_data

	, get_order_date
	
	, get_order_number
	
	, get_scfb
	
	, get_buyer_dept
	
	, get_delivery_address
	
	, check_comments
	
	, get_delivery_contact
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

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


	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Webber` )
	
	, type_of_supply( `01` )
	, cost_centre( `Standard` )
	
	, set( no_total_validation )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_imail_data, [ trace( [ `Process Both` ] ) ] ):- q_imail_data( self, `item_type`, `both` ).
%=======================================================================
i_rule( check_imail_data, [ 
%=======================================================================

	trace( [ `Process Second` ] )
	
	, check( Count = 1 )
	, set( chain, `junk` )
	, trace( [ `Junking first` ] )

] ):- q_imail_data( self, `item_type`, `dpc` ), i_mail( sub_document_count, Count ).

%=======================================================================
i_rule( check_imail_data, [ 
%=======================================================================

	trace( [ `Process First` ] )
	
	, check( Count = 2 )
	, set( chain, `junk` )
	, trace( [ `Junking Second` ] )

] ):- q_imail_data( self, `item_type`, `normal` ), i_mail( sub_document_count, Count ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCFB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_scfb, [ or( [ [ test( test_flag ), suppliers_code_for_buyer( `11265589` ) ], suppliers_code_for_buyer( `18009712` ) ] ) ] ):- i_mail( sub_document_count, 2 ).
%=======================================================================
i_rule( get_scfb, [ 
%=======================================================================

	  or( [ [ with( invoice, order_number, Order )
			, check( q_sys_sub_string( Order, 1, _, `PAV` ) )
			, or( [ [ test( test_flag ), suppliers_code_for_buyer( `11265586` ) ]
				, suppliers_code_for_buyer( `16879943` )
			] )
		]
		
		, [ q(0,20,line), generic_horizontal_details( [ [ `Bill`, `To` ] ] )
		
			, q(2,4,line), generic_horizontal_details_cut( [ nearest( generic_hook(start), 10, 10 ), city, sf, `,` ] )
			
			, or( [ [ check( city = `Irving` )
					, or( [ [ test( test_flag ), suppliers_code_for_buyer( `11265586` ) ]
						, suppliers_code_for_buyer( `16879943` )
					] )
				]
				
				, [ check( city = `The Woodlands` )
					, or( [ [ test( test_flag ), suppliers_code_for_buyer( `11265588` ) ]
						, suppliers_code_for_buyer( `13321638` )
					] )
				]
				
				, [ or( [ check( city = `Houston` ), check( city = `Jersey Village` ) ] )
					, or( [ [ test( test_flag ), suppliers_code_for_buyer( `11265587` ) ]
						, suppliers_code_for_buyer( `10747775` )
					] )
				]
			] )
		]
	] )
	
	, trace( [ `SCFB`, suppliers_code_for_buyer ] )
 
] ):- i_mail( sub_document_count, 1 ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER DEPT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_dept, [ 
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ gen_beof, `Entered`, `By` ], buyer_dept, s1 ] )
	
	, prepend( buyer_dept( `USWEB` ), ``, `` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER & DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ gen_beof, `Purchase`, `Order`, `#` ], order_number, s1 ] )
	  
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ gen_beof, `Sent` ], invoice_date, date ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	q(0,10,line), generic_horizontal_details( [ [ `Req`, `By` ], delivery_contact, s1 ] )

] ).

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	q(0,15,line), generic_horizontal_details( [ [ `Ship`, `To` ] ] )
 
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_party, s1 ] )
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_street, s1 ] )
	
	, q01(line), delivery_city_state_zip_line

] ).
	
%=======================================================================
i_line_rule( delivery_city_state_zip_line, [ 
%=======================================================================

	nearest( generic_hook(start), 10, 10 )
	
	, read_ahead( [ generic_item( [ dummy, s1 ] ) ] )
	
	, generic_item( [ delivery_city, sf, [ or( [ [ q10( `,` ), generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] ) ], [ `,`, generic_item( [ delivery_state, sf, read_ahead( num(d) ) ] ) ] ] ) ] ] )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )

] ).
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPECIAL INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
%=======================================================================
i_rule( check_comments, [ 
%=======================================================================

	q0n(line), generic_horizontal_details( [ [ `Special`, `Instructions` ] ] )
	
	, q0n(line)
	, generic_horizontal_details( [ or( [ `Pickup`, [ or( [ `Pick`, `Picked` ] ), `up` ], [ `picked`, `-`, `up` ], [ `will`, `call` ] ] ) ] )
	
	, q0n(line)
	, generic_horizontal_details( [ [ `Goods`, `and`, `services` ] ] )
	
	, remove( type_of_supply )
	, remove( cost_centre )
	
	, type_of_supply( `04` )
	, cost_centre( `Collection_Cust` )
	, set( exclude_zed )
	, additional_email_text( `- WILL CALL - REVIEW & RELEASE` )

] ).
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  qn0(line)
	  
	, generic_horizontal_details( [ [ or( [ at_start, tab ] ), `Exempt`, `Total` ], exempt, d, newline ] )
	, generic_horizontal_details( [ [ gen_beof, `Taxable`, `Total` ], taxable, d, newline ] )
	
	, check( sys_calculate_str_add( exempt, taxable, Net ) )

	, total_net( Net )
	, total_invoice( Net )
	
] ).

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [  line_invoice_rule
		  
				, line_check_line
			
				, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`Line`, q10( tab ), `Location`, q10( tab ), `Quantity`
	
	, q0n(anything), read_ahead( `Item` ), item_hook(w) 
	
	, q0n(anything), read_ahead( `Description` ), description_hook(w) 
	
	, q0n(anything), read_ahead( `Tax` ), tax_hook(w) 
	
] ).
	
%=======================================================================
i_line_rule_cut( line_end_line, [ q0n( [ dummy(s1), tab ] ), `Exempt`, `Total` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  q10( [ generic_line( [ generic_item( [ line_descr, s1, newline ] ) ] ), set( got_descr ) ] )
	  
	, line_invoice_line
 
	, q10( generic_line( [ [ peek_ahead( [ num(d), `items` ] ), append( line_descr(s1), ` `, `` ), newline ] ] ) )
	
	, clear( got_descr )

] ).

%=======================================================================
i_line_rule_cut( line_check_line, [
%=======================================================================

	  q0n(anything), thing( f( Format ) )
	  
	, q0n(anything), tab
	
	, q0n(anything), some(date)
	
	, force_sub_result( `missed_line` )
	, force_result( `defect` )

] )
:-
	i_mail( sub_document_count, Count ),
	( Count = 1
		->	Format = [ begin, q(dec,4,10), end ]
		
		; Format = [ q(alpha("DPC"),3,3), begin, q(dec,4,10), end ]
	)
.

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
	
	  generic_item_cut( [ line_order_line_number, d, q10( tab ) ] )
	  
	, generic_item_cut( [ location, w, q10( tab ) ] )
	
	, generic_item_cut( [ line_quantity, d ] )
	, or( [ generic_item( [ line_quantity_uom_code_x, w, q10( tab ) ] ), tab ] )
	
	, generic_item( [ line_item, Format, [ q10( dummy(s1) ), tab ] ] )

	, q01( [ sup_item(d), tab ] )
	
	, or( [ test( got_descr )
		, [ peek_fails( test( got_descr ) )
			, generic_item_cut( [ line_descr, s, [ q10( tab ), check( line_descr(end) < tax_hook(start) ) ] ] ) 
			]
	] )
	
	, q10( [ `â`, or( [ `ˆš`, tab ] ) ] )

	, generic_item_cut( [ line_unit_amount, d, q10( tab ) ] )

	, generic_item_cut( [ line_net_amount, d, q10( tab ) ] )
	
	, generic_item( [ line_date, date, newline ] )
	
] )
:-
	i_mail( sub_document_count, Count ),
	( Count = 1
		->	Format = [ begin, q(dec,4,10), end ]
		
		; Format = [ q(alpha("DPC"),3,3), begin, q(dec,4,10), end ]
	)
.

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).