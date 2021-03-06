%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US KMP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_kmp, `01 April 2015` ).

i_date_format( `m/d/y` ).

i_format_postcode( X, X ):- grammar_set( us ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

%=======================================================================
%	Email Subject Handling
%=======================================================================

%i_op_param( o_mail, _, _, _, i_mail_o_mail).
i_op_param( o_mail_subject, _, _, _, `rejected (by rule) – please enter manually` )
:-	data( invoice, delivery_note_reference, `by_rule` ).
i_op_param( o_mail_subject, _, _, _, `rejected (by rule) – revision` )
:-	data( invoice, delivery_note_reference, `revision` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ check_for_revision, get_country, get_fixed_variables ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_buyers_code_for_buyer
	
	, get_delivery_address

	, get_emails

	, get_order_date
	
	, get_order_number
	
	, get_contacts

	, get_invoice_lines

	, get_totals
	
	, check_notes_for_kmp
	
	, check_descriptions_for_kmp
	
	, set( enable_duplicate_check )

] ):- grammar_set( process_normally ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FAILURE CONDITION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_revision, [ or( [ [ q(0,5,line), revision_line ], set( process_normally ) ] ) ] ).
%=======================================================================
i_line_rule( revision_line, [ q0n(anything), `Revision`, delivery_note_reference( `revision` ) ] ).
%=======================================================================

%=======================================================================
i_line_rule( line_purchaser_line, [ `Purchaser` ] ).
%=======================================================================
i_rule( check_notes_for_kmp, [ peek_fails( test( manufacturer ) ),
%=======================================================================

	or( [ [ q0n(line)
	
			, read_ahead( generic_horizontal_details( [ [ at_start, word, `Notes`, `:` ], dummy, s1 ] ) )
			
			, read_the_notes
			
			, check( captured_text = Text )
			
			, trace( [ `captured`, captured_text ] )
			
			, check( string_to_upper( Text, Text_U ) )
			
			, check( q_sys_sub_string( Text_U, _, _, `KMP` ) )
		
			, trace( [ `Order notes passed` ] )
			
		]
		
		, [ set( no_kmp_notes )
		
			, trace( [ `Order notes failed` ] )
			
		]
		
	] )
	
] ).

%=======================================================================
i_line_rule( line_date_line, [ q0n(anything), some(date) ] ).
%=======================================================================
i_rule( read_the_notes, [ 
%=======================================================================

	gen1_parse_text_rule( [ -350, 500, or( [ line_purchaser_line, line_date_line, line_end_section_line, line_end_line ] )
						, something, [ begin, q(any,1,10), end ] ] )
	
] ).

%=======================================================================
i_rule( check_descriptions_for_kmp, [ peek_fails( test( manufacturer ) ),
%=======================================================================

	with( _, line_descr, Descr )
	  
	, or( [ [ check( q_sys_sub_string( Descr, _, _, `KMP` ) )
			
			, trace( [ `Order descr passed` ] )
			
		]

		, [ trace( [ `Order descr failed` ] )
		
			, set( no_kmp_descr )
			
		]
		
	] )
		
	, q10( [ test( no_kmp_descr ), test( no_kmp_notes )
	
		, delivery_note_reference( `by_rule` )
		
		, trace( [ `Failed` ] )
		
	] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COUNTRY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_country, [ 
%=======================================================================

	q(0,20,line), generic_horizontal_details( [ read_ahead( [ `Vendor`, `:` ] ), hook, s1 ] )
	
	, q(0,10,line), generic_horizontal_details( [ [ nearest( hook(start), 10, 10 ), q0n(word), read_ahead( `Canada` ) ], country, w ] )
	
	, set( ca )
	
] ).

%=======================================================================
i_rule( get_country, [ 
%=======================================================================

	or( [ [ q(0,20,line), generic_horizontal_details( [ read_ahead( [ `Ship`, `To`, `:` ] ), hook, s1 ] )
	
			, q(0,10,line), generic_horizontal_details( [ nearest( hook(start), 10, 10 ), country, [ begin, q(alpha,2,2), end ] ] )
			
			, or( [ [ check( country = `US` ), set( us ) ]
			
				, [ check( country = `CA` ), set( ca ) ] 
				
			] )
			
		]
			
		, [ force_result( `defect` ), force_sub_result( `unable_to_determine_country` ) ]
		
	] )
		
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

	, or( [ [ test( ca ), buyer_registration_number( `CA-ADAPTRI` ) ]
		, buyer_registration_number( `US-ADAPTRI` )
	] )

	, or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	])

	, agent_name(`US_ADAPTRIS`)
	, or( [ [ test( ca ), agent_code_3(`6800`) ]
		, agent_code_3(`6000`)
	] )
	
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, type_of_supply( `01` )
	
	, sender_name( `Kiewit Marketplace` )
	
	, cost_centre( `Standard` )
	
	, set( no_uom_transform )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q(0,10,line), delivery_header_line( [ Left ] )

	, delivery_thing_line( 1, Left, 200, [ delivery_party ] )
	
	, q10( delivery_thing_line( 1, Left, 200, [ delivery_dept ] ) )
	
	, q01( delivery_thing_line( 1, Left, 200, [ delivery_address_line ] ) )
	
	, delivery_thing_line( 1, Left, 200, [ delivery_street ] )

	, delivery_city_state_postcode_line( 2, Left, 200 )
	
] ).

%=======================================================================
i_line_rule( delivery_header_line( [ Left ] ), [ 
%=======================================================================

	  q0n(anything)
	  
	, read_ahead( [ `Ship`, `To` ] ), hook(w)
	
	, check( hook(start) = Start )
	
	, check( sys_calculate( Left, Start - 5 ) )
	
	,  trace( [ `found header` ] )
	
] ).

%=======================================================================
i_line_rule( delivery_thing_line( [ Variable ] ), [ generic_item( [ Variable, s1 ] ) ] ).
%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [ 
%=======================================================================

	  generic_item( [ delivery_city, sf ] )
	
	, q(2,2, or( [ [ without( delivery_state ), generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] ) ]
	
			, [ without( delivery_postcode )
			
				, q01( set(regexp_cross_word_boundaries ) )
				
				, generic_item( [ delivery_postcode, Format ] )
	
				, q10( [ peek_fails( test( ca ) )
				
					, append( delivery_postcode(f( [ begin, q(other("-"),1,1), q(dec,4,4), end ] ) ), ``, `` )

				] )
			
				, clear( regexp_cross_word_boundaries )
				
			]
			
		] )
		
	)

] )
:-	
	( grammar_set( ca )
		->	Format = [ begin, q(alpha,1,1), q(dec,1,1), q(alpha,1,1)
							,q(dec,1,1),q(alpha,1,1),q(dec,1,1), end ]
							
		;	Format = [ begin, q(dec,5,5), end ]
	)
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	BUYERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyers_code_for_buyer, [ 
%=======================================================================

	  q(0,5,line), generic_vertical_details( [ [ `Bill`, `To` ], `Bill`, part_of_code, s1, tab ] )
	  
	, check( part_of_code = Part_Two_x )
	
	, check( strip_string2_from_string1( Part_Two_x, ` `, Part_Two ) )
	
	, or( [ [ test( ca ), check( Pre = `CAKMP` ) ]
		, [ test( us ), check( Pre = `USKMP` ) ]
	] )
	
	, check( strcat_list( [ Pre, Part_Two ], BCFB ) )
	
	, buyers_code_for_buyer( BCFB )
	
	, trace( [ `BCFB`, buyers_code_for_buyer ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * CONTACT DETAILS * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,7,line), generic_horizontal_details( [ [ `PO`, `Number`, `:` ], order_number, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Date`, `Ordered` ], invoice_date, date, newline ] )
	  
] ).

%=======================================================================
i_rule( get_emails, [ 
%=======================================================================

	  q(0,25,line)
	  
	, or( [ generic_horizontal_details( [ [ `Email`, `:` ], 200, buyer_email, s1, newline ] )
	
		, [ generic_horizontal_details( [ read_ahead( [ `Email`, `:`, newline ] ), dummy, s1 ] )
		
			, generic_horizontal_details( [ read_ahead( [ q0n(word), `@` ] ), buyer_email, s1 ] )
			
		]
		
	] )
  
	, check( buyer_email = Email )
	
	, delivery_email( Email )

] ).

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Buyer`, `:` ], 200, buyer_contact, s1, newline ] )
	  
	, check( buyer_contact = Con )
	
	, delivery_contact( Con )

] ).

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ `Total`, `Value`, `:` ], total_net, d, or( [ `USD`, `CAD` ] ) ] )

	, check( total_net = Net )
	
	, total_invoice( Net )
	
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ `Page`, num(d), `of` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, qn0( [ peek_fails(line_end_line)

		, or( [  line_invoice_rule
		
				, line_freight_line
			
				, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	read_ahead( [ `Item`, tab, `Product` ] )

	, q0n(anything), read_ahead( `Product` ), product_hook(w)
	
	, q0n(anything), read_ahead( `description` ), descr(w) 
	
	, q0n(anything), read_ahead( `qty` ), qty(w)
	
	, q0n(anything), read_ahead( `UOM` ), uom_hook(w)
	
	, q0n(anything), read_ahead( `Price` ), price_hook(w)
	
	, q0n(anything), read_ahead( `Tax` ), tax_hook(w)
	
	, q0n(anything), read_ahead( `Delivery` ), delivery_hook(w)
	
	, q0n(anything), read_ahead( `Amount` ), amount_hook(w)
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [ `Total`, `Value` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, or( [ check( line_item_x = Item )
	
		, [ test( missing_item ), check( Item = `Missing` ) ]
		
	] )

	, or( [ [ q10( [ line_continuation_line ] )

			, line_item_and_descr_line
			
			, q10( [ line_continuation_line ] )
			
		]
		
		, [ q(2,0, [ peek_fails( line_end_line ), line_continuation_line ] )
			
			, line_item_for_buyer( Item )
			
		]
		
	] )
	
	, or( [ [ q0n( line_continuation_line ), manufacturer_descr_line ], line_item( Item ) ] )
	
	, clear( need_descr )
	
	, clear( missing_item )

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ line_descr_rule ] ).
%=======================================================================
i_rule( line_descr_rule, [ 
%=======================================================================

	or( [ [ test( need_descr ), generic_item( [ line_descr, s1 ] ) ]
	
		, append( line_descr(s1), `~`, `` )
		
	] )
		
	, newline 
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  check( product_hook(start) = Prod )
	, check( descr(start) = Descr )
	, check( qty(start) = Qty )
	, check( uom_hook(start) = UoM )
	, check( price_hook(start) = Price )
	, check( tax_hook(start) = Tax )
	, check( delivery_hook(start) = Del )
	, check( amount_hook(start) = Amt )
	
	, retab( [ Prod, Descr, Qty, UoM, Price, Tax, Del, Amt ] )
	
	, generic_item_cut( [ line_order_line_number, d, [ q10( word ), tab ] ] )
	
	, or( [ [ q10( or( [ `MC`, `Hilti` ] ) )
			, generic_item_cut( [ line_item_x, s1, tab ] ) 
		]
	
		, [ set( missing_item ), tab ]
		
	] )

	, or( [ generic_item_cut( [ line_descr, s, tab ] )
		
		, [ set( need_descr ), tab ]
		
	] )
	
	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item_cut( [ some_uom, [ begin, q(alpha,1,5), end ], tab ] )
	
	, generic_item_cut( [ line_unit_amount, d, [ or( [ `USD`, `CAD` ] ), `/` ] ] )
	
	, generic_item_cut( [ num, d, [ word, tab ] ] )
	
	, generic_item_cut( [ taxable, s1, tab ] )
	
	, or( [ generic_item_cut( [ some_date, date, tab ] )
	
		, [ dum(d), `/`, q10( dum(d) ), `/`, dum(d), tab, trace( [ `Incomplete date found` ] ) ]
		
	] )
	
	, generic_item_cut( [ line_net_amount, d, [ or( [ `USD`, `CAD` ] ), newline ] ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_and_descr_line, [
%=======================================================================
   
	  peek_fails( 
	  
		or( [ `External`

			, `Manufacturer`
			
			, [ q0n(word), `Notes` ]
			
		] )
		
	)
	  
	, generic_item_cut( [ line_item_for_buyer, s1, tab ] )

	, line_descr_rule
	
] ).

%=======================================================================
i_line_rule_cut( manufacturer_descr_line, [
%=======================================================================
   
	  `Manufacturer`, `Part`, `Number`, `:`, tab
	  
	, generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ] ] )
	
	, set( manufacturer )
	
	, q10( append( line_descr(s1), `~`, `` ) )
	
] ).

%=======================================================================
i_line_rule_cut( line_freight_line, [
%=======================================================================
   
	  generic_item_cut( [ line_order_line_number, d, tab ] )
	  
	, read_ahead( [ q0n(word), `Freight` ] )
	
	, generic_item_cut( [ line_descr, s1, tab ] )
	
	, qn0(anything), tab
	
	, generic_item( [ line_net_amount, d, [ or( [ `USD`, `CAD` ] ), newline ] ] )
	
	, line_item( `Missing` )
	
	, line_type( `Freight` )
	
	, check( line_net_amount = Net )
	
	, delivery_charge( Net )
	
] ).
