%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - RAVATE PROFESSIONNEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ravate_professionnel, `19 March 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_pdf_parameter( x_tolerance_100, 100 ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1 ).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1 ).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_capture( [ [  `F`, `O`, `U`, `R`, `N`, `I`, `S`, `S`, `E`, `U`, `R`, tab, `N`, `o` ], order_number, w, `du` ] )
	, gen_capture( [ [ tab, `du` ], invoice_date, date, newline ] )
	
	, get_delivery_address

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `FR-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0900`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10558391` ) ]	
				, suppliers_code_for_buyer( `11675021` )		
	] )

	, sender_name( `Ravate Professionnel` )
	
	, type_of_supply( `F5` )
	
	, buyer_contact( `Christel DELAGE` )
	, delivery_contact( `Christel DELAGE` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================	  
	  
	  q10(line)
	
	, generic_horizontal_details( [ at_start, delivery_party, s1 ] )
	
	, generic_horizontal_details( [ at_start, delivery_street, s1 ] )
	
	, generic_horizontal_details( [ at_start, delivery_dept, s1 ] )
	
	, delivery_postcode_and_city_line
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================	  
	  
	  generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [
		
			generic_horizontal_details( [ [ `-`, `-`, `-`, `-`, `-` ] ] )
			
			, generic_line( [ [ qn0( [ `:`, tab ] ), `:`, newline ] ] )
			
			, line_invoice_rule

			, line

		] )

	] )

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `:`, tab, `:`, `Code`, `int`, `.`, `Gencod`, tab ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [
	
		[ `:`, tab, `Total`, `Commande`, `:` ]
		
		, [ `RAVATE`, newline ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	  line_invoice_line

	, q10( [ test( double_line ), check( sys_calculate_str_divide( line_unit_amount_x, `2`, UNIT ) )
		
		, or( [
		
			[ test( cent ), check( sys_calculate_str_multiply( line_quantity_x, UNIT, NET ) ), line_net_amount(NET) ]
		
			, line_unit_amount(UNIT)
		
		] )
		
		, check( line_item_x = ITEM ), line_item(ITEM)
		, check( line_quantity = QTY ), line_quantity(QTY)
		, check( line_quantity_uom_code = UOM ), line_quantity_uom_code(UOM)
		, check( line_descr = DESCR ), line_descr(DESCR)
		
		, or( [
		
			[ test( cent ), line_net_amount(NET) ]
			
			, line_unit_amount(UNIT)
			
		] )
		
		, count_rule
		
		, trace( [ `created extra line` ] )
		
	] )
	
	, q10( [ test( ignore_line )
	
		, line_type( `ignore` )
		
		, check( sys_calculate_str_multiply( line_quantity, line_unit_amount, NET ) )

		, delivery_charge( NET )
		
		, trace( [ `ignored line with no line item` ] )
		
	] )
	
	, clear( double_line ), clear( cent ), clear( ignore_line ), clear( boite )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  `:`, q10(tab)
	
	, line_no(d), `:`, tab
	
	, or( [
	
		[ generic_item( [ line_item, [ begin, q(dec,4,10), end, q(any,0,1) ] ] )
	
			, q10( [ 
			
				or( [ [ q10(`+`), q10(`(`), q10(`EX`)
			
						, generic_item( [ line_item_x, [ begin, q(dec,4,10), end, q(any,0,1) ] ] )
						
						, q10(`)`)
					
						, set( double_line )
						
					]
					
					, [ `(`, `Pack`, dummy(s) ]
					
				] )
				
			] )
			
			, q10(tab)
			
		]
		
		, set( ignore_line )
		
	] )
	
	, `:`, tab
	
	, line_quantity_x(d), `:`
	
	, or( [
	
		[ read_ahead(`CENT`)
			, check( sys_calculate_str_multiply( `100`, line_quantity_x, QTY ) )
			, set( cent )
			
		]
		
		, [ read_ahead( [ a(sf), `:`, `BOITE`, multiplier(d) ] )
			, check( sys_calculate_str_multiply( multiplier, line_quantity_x, QTY ) )
			, set( boite )
		]
		
		, check( line_quantity_x = QTY )
		
	] )
	
	, line_quantity(QTY), trace( [ `line_quantity`, line_quantity ] )
	
	, generic_item( [ line_quantity_uom_code, sf, `:` ] )
	
	, generic_item( [ line_descr, s, q10(tab) ] )
	
	, `:`, tab
	
	, or( [
	
		[ read_ahead( [ `0`, `.`, or( [ `01`, `00` ] ) ] ), generic_item( [ line_unit_amount, d ] )
			, set( ignore_line ), clear( double_line )
		]
	
		, [ test( double_line ), generic_item( [ line_unit_amount_x, d ] ) ]
		
		, [ or( [ test( cent ), test( boite ) ] ), generic_item( [ line_unit_amount_x, d ] )
			, check( sys_calculate_str_multiply( line_quantity_x, line_unit_amount_x, NET ) )
			, line_net_amount(NET)
		]
		
		, generic_item( [ line_unit_amount, d ] )
		
	] )
	
	, tab, `EUR`, `:`, newline
	
	, count_rule

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ `Total`, `Commande`, `:` ], total_net, d ] )

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