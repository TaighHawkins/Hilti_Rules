%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - KBAC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( kbac, `18 May 2015` ).

i_supplier_rule( invoice_check_rule ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1 ).

i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1 ).

i_user_field( invoice, net_subtotal_x, `net_storage` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 buyer_party( `LS` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `CA-ADAPTRI` )

	, [ or([ 
			[ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
			, supplier_registration_number( `P11_100` )                      %PROD
		]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`6800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
			[ test(test_flag), suppliers_code_for_buyer( `11236844` ) ]    %TEST
			, suppliers_code_for_buyer( `19130981` )                      %PROD
		]) ]

	, [ or([ 
			[ test(test_flag), delivery_note_number( `11236844` ) ]    %TEST
			, delivery_note_number( `19308155` )                      %PROD
		]) ]

		
	, get_buyer_email
	
	, get_buyer_contact
	
	, type_of_supply_rule
	
	, other_type_of_supply_line
	
	, get_order_date
		
	, get_delivery_contact_numbers
	
	, get_delivery_contact_email
	
	, get_delivery_contact

	, [ q0n(line), order_number_line ]
	
	, get_invoice_lines
	
	, get_totals

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( invoice_check_rule, [
%=======================================================================

	peek_fails( [ q0n(line), invoice_check_line ] )

] ).

%=======================================================================
i_line_rule( invoice_check_line, [
%=======================================================================

	q0n(anything)
	
	, or( [ [ `Request`, `for`, `Quote` ]
	
			, [ `Purchase`, `Requisition` ]
			
			, [ `Subtotal`, tab, `0`, `.`, `00`, newline ]
			
			, [ repair_in_description_rule ]
			
		] ) 

] ).

%=======================================================================
i_rule( repair_in_description_rule, [
%=======================================================================

	  read_ahead( [ `Repair`, q10( `part` ) ] )
	  
	, repair(w)
	
	, check( repair(start) < 75 )
	
	, check( repair(end) > -180 )

] ).

	 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER EMAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	  buyer_email(FROM)
	  
	] )
	
	:-
	
	i_mail(from,FROM)
	
	.

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TYPE OF SUPPLY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( type_of_supply_rule, [
%=======================================================================

	  q0n(line), type_of_supply_line
	  
	] ).
	
%=======================================================================
i_line_rule( type_of_supply_line, [
%=======================================================================

	  q0n(anything)
	  
	, read_ahead( [ 
							or( [ `Air`

								, [ `Freight`, `Change` ]
								
							] )
							
		] )
		
	, air(w)
	
	, check( air(start) > -350 )
				
	, check( air(end) < -200 )
				
	, type_of_supply( `N7` )
				
	, cost_centre( `HNA:Air Priority` )
	
] ).
				
%=======================================================================
i_line_rule( other_type_of_supply_line, [
%=======================================================================

	  without( type_of_supply)
	  
	, type_of_supply( `01` )
			
	, cost_centre( `standard` )
	  
	] ).
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [
%=======================================================================

	  q0n(line), find_subtotal_line
	  
	, q(0,5,line), buyer_contact_line
	  
	] ).
	
%=======================================================================
i_line_rule( find_subtotal_line, [
%=======================================================================

	  q0n(anything), `Subtotal`
	  
	] ).
	
%=======================================================================
i_line_rule( buyer_contact_line, [
%=======================================================================

	  buyer_contact(s1), tab
	  
	, check( buyer_contact(start) > -200)
	
	, check( buyer_contact(end) < 0 )
	
	, trace( [ `buyer contact`, buyer_contact ] )
	  
	] ).
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q0n(line), order_date_line

] ).

%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================

	  q0n(anything), `date`, invoice_date(date), newline
	  
	, check( invoice_date(y) < 0 )
	  
	, trace( [ `invoice date`, invoice_date ] )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact_numbers, [ 
%=======================================================================

	  q0n(line), delivery_numbers_line
		
] ).

%=======================================================================
i_line_rule( delivery_numbers_line, [ 
%=======================================================================

	  q0n(anything)
	  
	,`Phone`, `:`
	  
	, delivery_ddi(s1), tab
	
	, check( delivery_ddi(start) > 0 )
	
	, trace( [ `delivery contact ddi`, delivery_ddi ] )
	
	, `Fax`, `:`
	
	, delivery_fax(s1), newline
	
	, trace( [ `delivery contact fax`, delivery_fax ] )

] ).


%=======================================================================
i_rule( get_delivery_contact_email, [ 
%=======================================================================

	  q0n(line), delivery_contact_email_line
		
] ).

%=======================================================================
i_line_rule( delivery_contact_email_line, [ 
%=======================================================================

	  q0n(anything)
	  
	, `Email`, `:`
	
	, delivery_email(s1), newline
	
	, check( delivery_email(start) > 0 )
	
	, trace( [ `delivery contact email`, delivery_email ] )

] ).

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	  q0n(line), delivery_contact_line
		
] ).

%=======================================================================
i_line_rule( delivery_contact_line, [ 
%=======================================================================

	  q0n(anything)
	  
	, `Notify`, `Upon`, `Receipt`, `:`
	
	, delivery_contact(w)
	
	, check( delivery_contact(start) > 0 )
	
	, q10( append( delivery_contact(w), ` `, `` ) )
	
	, q0n(word)
	
	, trace( [ `delivery contact`, delivery_contact ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================

	  q0n(anything), `Number`, order_number(s1), newline
	  
	, check( order_number(start) > 0 ) 
	  
	, trace( [ `order number`, order_number ] )
	

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( get_totals, [ 
%=======================================================================

	  q0n(line), total_net_line

] ).

%=======================================================================
i_line_rule_cut( total_net_line, [ 
%=======================================================================

	  q0n(anything), `Subtotal`, tab, total_invoice(d), newline
	
	, trace( [ `total invoice`, total_invoice ] )
	
	, with( invoice, net_subtotal_2, NET_2 )
	
	, check( sys_calculate_str_subtract(total_invoice, NET_2, NET ) )
	
	, net_subtotal_1( NET )
	
	, gross_subtotal_1( NET )
	
	, trace( [ `net 1`, net_subtotal_1 ] )
	
	, trace( [ `gross 1`, gross_subtotal_1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, net_subtotal_x( `0` )

	, qn0( [ peek_fails(line_end_line)

		, or( [ air_freight_check_line
		
				, line_invoice_first_rule
		
				, line_invoice_second_rule
				
				, line_invoice_second_v2_rule
				
				, line_invoice_third_rule
				
				, line_invoice_fourth_rule
		
				, line

			])

		] )
		
	, subtotal_calculation_rule
	
] ).

%=======================================================================
i_rule_cut( subtotal_calculation_rule, [ 
%=======================================================================

	  check( i_user_check( gen_same, net_subtotal_x, NET_X ) )
	  
	, net_subtotal_2( NET_X )
	
	, gross_subtotal_2( NET_X )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	  `Ln`, tab, `Qty`, `Unit`, `Item` 

	, trace( [ `found header` ] )

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  q0n(anything), `Subtotal`, tab

] ).

%=======================================================================
i_line_rule_cut( air_freight_check_line, [
%=======================================================================

	  q0n(anything)
	  
	, read_ahead( [ 
		
		or( [ 
		
			[ or( [ [`Air`, q10( `freight`) ]
		
					, [ `Freight`, `Change`]
					
					, `Freight`
					
					, [ `Air`, `Freight`, `Charge` ]
		
				] ), tab 
	
			]
	
			, [ `Fuel`, `Surcharge` ]
	
		] )
	
	] )
	  
	, air_freight(s1)
	
	, trace( [ `air`, air_freight ] )
	
	, check( air_freight(end) < -200 )
	
	, trace( [ `skipping air freight line` ] )
	
	, q0n(anything)
	
	, tab, net_subtotal_y(d), newline
	
	, check( sys_calculate_str_add( net_subtotal_y, net_subtotal_x, RUNNING ) )
	
	, net_subtotal_x( RUNNING )
	
	, trace( [ `after addition`, net_subtotal_x] )
	
	, trace( [ `captured air freight net` ] )

] ).

%=======================================================================
i_rule_cut( line_invoice_first_rule, [
%=======================================================================

	  trace( [ `in first` ] )
	
	, read_ahead( line_item_first_rule )
	  
	, line_invoice_line_type_one
	
	, q(2,0,line_continuation_line)
	
	, line_invoice_tax_line
	
	, line_tax_waste_line
	
	, line_gross_line

] ).

%********************************************************************************
%********************************************************************************
%=======================================================================
i_rule_cut( line_item_first_rule, [
%=======================================================================

	  or( [ line_item_after_hash_line
	  
			, [ line_with_hash_line, line_item_first_thing ]
			
			, [ line, line_item_after_hash_line ]
			
			] )

] ).

%=======================================================================
i_line_rule_cut( line_item_after_hash_line, [
%=======================================================================

	  q0n(anything), or( [ `#`, [ `p`, `/`, `n` ] ] ), line_item(f( [ begin, q(dec,5,9), end ] ) )
	
] ).

%=======================================================================
i_line_rule_cut( line_with_hash_line, [
%=======================================================================

	  q0n(anything), or( [ `#`, [ `p`, `/`, `n` ] ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_first_thing, [
%=======================================================================

	 line_item(f( [ begin, q(dec,5,9), end ] ) )
	  
	, trace( [ `line item`, line_item ] )	
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_type_one, [
%=======================================================================

	  retab( [ -420, -380, -345, -180, 75, 155, 200, 390 ] )
	
	, line_no_rule
	
	, line_quantity_rule
	
	, line_quantity_uom_code_rule
	
	, fake_item_rule
	
	, line_descr_rule
	
	, cost_code_rule
	
	, exp_rule
	
	, line_unit_amount_rule
	
	, line_net_amount_rule
	
] ).

%=======================================================================
i_rule_cut( line_no_rule, [
%=======================================================================

	  line_no(d), tab
	
] ).

%=======================================================================
i_rule_cut( line_quantity_rule, [
%=======================================================================

	  line_quantity(d), tab
	
	, trace( [ `line quantity`, line_quantity ] )
	
] ).

%=======================================================================
i_rule_cut( line_quantity_uom_code_rule, [
%=======================================================================

	  line_quantity_uom_code_x(w), tab
	
	, trace( [ `qty uom`, line_quantity_uom_code_x ] )
	
] ).

%=======================================================================
i_rule_cut( fake_item_rule, [
%=======================================================================

	  fake_item(s1), tab
	  
	, trace( [ `fake item`, fake_item ] )
	
] ).

%=======================================================================
i_rule_cut( line_descr_rule, [
%=======================================================================

	  line_descr(s1), tab 
	
	, trace( [ `line_descr`, line_descr ] )
	
] ).

%=======================================================================
i_rule_cut( cost_code_rule, [
%=======================================================================

	  cost_code(s), tab
	  
	, trace( [ `cost code`, cost_code ] )
	
] ).

%=======================================================================
i_rule_cut( exp_rule, [
%=======================================================================

	  exp(w), tab
	  
	, trace( [ `exp`, exp ] )
	
] ).

%=======================================================================
i_rule_cut( line_unit_amount_rule, [
%=======================================================================

	  line_unit_amount(d), tab
	
	, trace( [ `unit amount`, line_unit_amount ] )
	
] ).

%=======================================================================
i_rule_cut( line_net_amount_rule, [
%=======================================================================

	  line_net_amount(d), newline
	
	, trace( [ `line net`, line_net_amount ] )	
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_tax_line, [
%=======================================================================

	  cost_code_rule
	
	, exp_rule
	
	, dummy_unit_amount_rule
	
	, line_vat_amount_x(d), newline
	  
	, trace( [ `line vat amount`, line_vat_amount_x ] )
	
] ).

%=======================================================================
i_rule_cut( dummy_unit_amount_rule, [
%=======================================================================

	  dummy_unit_amount(d), tab
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	retab( [ -180 ] )

	, or( [ [ q01( dumb_item(s1) ), tab

			, append( line_descr(s1), ` `, `` ), newline
		]
		
		, dumb_item(s1), tab, newline
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_tax_waste_line, [
%=======================================================================

	  `(`, `Tax`, `)`, newline
	  
	, trace( [ `tax waste` ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_gross_line, [
%=======================================================================

	  dummy_line_gross_amount(d), newline
	  
	, trace( [ `dummy gross` ] )
	
] ).

%********************************************************************************
%********************************************************************************
%=======================================================================
i_rule_cut( line_invoice_second_rule, [
%=======================================================================

	  trace( [ `in second` ] )
	  
	, line_invoice_line_type_one
	
	, q10(line_continuation_line)
	
	, line_invoice_tax_line
	
	, line_tax_waste_line
	
	, line_gross_line
	
	, line_item_number_two_rule

] ).

%=======================================================================
i_rule_cut( line_invoice_second_v2_rule, [
%=======================================================================

	  trace( [ `in second v2` ] )
	  
	, line_invoice_line_type_one
	
	, q10(line_continuation_line)
	
	, line_invoice_tax_line
	
	, line_tax_waste_line
	
	, line_gross_line
	
	, per_box_line
	
	, line_item_number_two_rule

] ).

%=======================================================================
i_line_rule_cut( per_box_line, [
%=======================================================================

	  q0n(word), `per`, `box`
	  
	, trace( [ `per box line` ] )
	
] ).

%=======================================================================
i_rule_cut( line_item_number_two_rule, [
%=======================================================================

	  line_item_number_two_line
	  
	, peek_fails( line_item_number_two_line )

] ).

%=======================================================================
i_line_rule_cut( line_item_number_two_line, [
%=======================================================================

	  q01(word), q10(`#`)
	  
	, line_item(f( [ begin, q(dec,5,9), end ] ) ), q0n(word), newline
	  
	, check( line_item(end) < 200 )
	
] ).

%********************************************************************************
%********************************************************************************
%=======================================================================
i_rule_cut( line_invoice_third_rule, [
%=======================================================================

	  trace( [ `in third` ] )
	
	, line_invoice_line_type_two
	
	, q10(line_continuation_line)
	
	, line_invoice_tax_line
	
	, line_tax_waste_line
	
	, line_gross_line

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_type_two, [
%=======================================================================

	  retab( [ -420, -380, -345, -180, 75, 155, 200, 390 ] )
	
	, line_no_rule
	
	, line_quantity_rule
	
	, line_quantity_uom_code_rule
	
	, q10(`*`)
	
	, or( [ line_item(f( [ begin, q(dec,5,9), end ] ) )

		, [ or( [ [ `AIR`, `FREIGHT` ]

				, `AIR`

				, [ `Freight`, `Change` ] 
				
			] )
			
		, line_item( `Missing` ) ]

		, line_item(s1)	

	] )
	
	, tab
	
	, line_descr_rule
	
	, cost_code_rule
	
	, exp_rule
	
	, line_unit_amount_rule
	
	, line_net_amount_rule	
	
] ).

%********************************************************************************
%********************************************************************************
%=======================================================================
i_rule_cut( line_invoice_fourth_rule, [
%=======================================================================

	  trace( [ `in fourth` ] )
	
	, line_invoice_line_type_three
	
	, q10(line_continuation_line)
	
	, line_invoice_tax_line
	
	, line_tax_waste_line
	
	, line_gross_line

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_type_three, [
%=======================================================================

	  retab( [ -420, -380, -345, -180, 75, 155, 200, 390 ] )
	
	, line_no_rule
	
	, line_quantity_rule
	
	, line_quantity_uom_code_rule
	
	, q10( [ `*`] ), tab , line_item( `Missing` )
	
	, line_descr_rule
	
	, cost_code_rule
	
	, exp_rule
	
	, line_unit_amount_rule
	
	, line_net_amount_rule		
	
] ).

i_op_param( orders05_idocs_first_and_last_name( buyer_contact, NAME1, `K B A C CONSTRUCTORS` ), _, _, _, _) :- result( _, invoice, buyer_contact, NU ), string_to_upper(NU, NAME1).

i_op_param( orders05_idocs_first_and_last_name( delivery_contact, NAME2, `K B A C CONSTRUCTORS` ), _, _, _, _) :- result( _, invoice, delivery_contact, NU2 ), string_to_upper(NU2, NAME2).

