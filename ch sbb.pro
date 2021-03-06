%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CH SBB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


i_version( ch_sbb, `01 April 2015` ).
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
	
	, get_order_number
	
	, get_order_date
	
	, get_due_date
	
	, get_buyers_code_for_buyer
	
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

	, buyer_registration_number( `CH-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2100`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q0n(line), delivery_header_line
	  
	, delivery_thing_line( [ delivery_party ] )
	
	, delivery_thing_line( [ delivery_dept ] )
	
	, q10( delivery_thing_line( [ delivery_address_line ] ) )

	, delivery_thing_line( [ delivery_street ] )
	
	, delivery_city_postcode_line
	  
] ).

%=======================================================================
i_line_rule( delivery_header_line, [ `Anlieferadresse`, `:` ] ).
%=======================================================================
i_line_rule( delivery_thing_line( [ Variable ] ), [ 
%=======================================================================

	  Read_Var
	  
	, trace( [ String, Variable ] )
	
] ):-

	Read_Var =.. [ Variable, s1 ]
	, sys_string_atom( String, Variable )
.


%=======================================================================
i_line_rule( delivery_city_postcode_line, [ 
%=======================================================================
	
	  delivery_postcode(f( [ begin, q(dec,4,5), end ] ) )
	  
	, delivery_city(s1)
	
	, trace( [ `other delivery stuffs`, delivery_postcode, delivery_city ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * CONTACT DETAILS * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Bestellung` ], order_number, s1, tab ] )
	  
] ).

%=======================================================================
i_line_rule( buyer_contact_header_line, [ q0n(anything), `AnsprechpartnerIn`, `/`, `Telefon` ] ).
%=======================================================================
i_line_rule( buyer_contact_and_ddi_line, [ q0n(anything), generic_item( [ buyer_contact, sf, `/` ] ), generic_item( [ buyer_ddi, s1 ] ) ] ).
%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,5,line), buyer_contact_header_line
	  
	, q01( line ), buyer_contact_and_ddi_line
	
	, check( buyer_contact = Con )
	
	, check( buyer_ddi = DDI )
	
	, delivery_contact( Con )
	
	, delivery_ddi( DDI )
	
	, q01( line), generic_horizontal_details( [ [ `E`, `-`, `Mail`, `:` ], buyer_email, s1, newline ] )
	 
] ).


%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Bestellung`, dummy(s1) ], 600, invoice_date, date, newline ] )
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Liefertermin` ], 200, due_date, date, newline ] )
	  
] ).

%=======================================================================
i_rule( get_buyers_code_for_buyer, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Buchungskreis` ], bcfb, s1, newline ] )
	  
	, check( bcfb = BCFB )
	
	, wrap( buyers_code_for_buyer( BCFB ), `CHSBB`, `` )
	  
] ).

%=======================================================================
i_rule( get_totals, [ q0n(line), totals_line ] ).
%=======================================================================
i_line_rule( totals_line, [
%=======================================================================

	  `Gesamtnettowert`, `ohne`, `Mwst`, `CHF`, tab
	  
	, read_ahead( [ generic_item( [ total_net, d, newline ] ) ] )
	
	, generic_item( [ total_invoice, d, newline ] )

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
i_line_rule_cut( line_end_section_line, [ `Schweizerische`, `Bundesbahnen`, `SBB` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	  
	, line_underscore_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		or( [  line_invoice_rule
			
				, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Bestellmenge`, tab, `Einheit` ] ).
%=======================================================================
i_line_rule_cut( line_underscore_line, [ `_`, `_`, `_` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Gesamtnettowert`, `ohne`, `Mwst`, `CHF` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_descr_line
	 
	, line_values_line
	
	, or( [ line_item_line, line_item( `Missing` ) ] )
	
	, or( [ peek_fails( test( discounted_line ) )
	
		, [ test( discounted_line )
		
			, q(0,5,line), line_bruttopreis_line
			
			, q(0,3,line), line_discounted_values_line
			
		]
		
	] )
	
	, count_rule

	, with( invoice, due_date, DATE )
	
	, line_original_order_date( DATE )
	
] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================
   
	  generic_item( [ line_no, d, tab ] )
	
	, generic_item( [ line_descr, s1, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================
   
	  generic_item( [ line_quantity, d, tab ] )
	  
	, or( [ [ generic_item( [ line_quantity_uom_code, s1, tab ] )
	
			, generic_item_cut( [ line_unit_amount, d ] )
			
			, q10( [ `/`, num(d) ] ), tab
	
			, generic_item( [ line_net_amount, d, newline ] )
			
		]
		
		, [ generic_item( [ line_quantity_uom_code, s1, newline ] )
		
			, set( discounted_line )
			
		]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================
   
	  `Ihre`, `Materialnummer`, `:`, tab
	  
	, generic_item( [ line_item, [ begin, q(dec,3,10), end ], newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_bruttopreis_line, [ `Bruttopreis` ] ).
%=======================================================================
i_line_rule_cut( line_discounted_values_line, [
%=======================================================================
   
	  `Nettowert`, dummy(s1), tab
	  
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, word, tab
	
	, generic_item( [ line_price_uom_code, w, [ q10( word ), tab ] ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_rule( count_rule, [
%=======================================================================
   
	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	
	, line_order_line_number(NEXT_LINE_NUMBER)
	
] ).