%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - GUEDEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( guedel, `10 April 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables
	
	, get_order_number
	
	, check_for_anderung
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FAILURE RULE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_anderung, [ 
%=======================================================================

	q(0,30,line)
	
	, generic_horizontal_details( [ [ `Änderung`, `zur`, `Bestellung` ] ] )
	
	, delivery_note_number( `special_rule` )
	
	, set( do_not_process )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_delivery_address

	, get_buyer_contact
	
	, get_order_number
	
	, get_order_date

	, get_invoice_lines

	, get_totals

] ):- not( grammar_set( do_not_process ) ).

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
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10401811` ) ]
		, suppliers_code_for_buyer( `10538777` )
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q(0,10,line), delivery_header_line
	  
	, q01(line), delivery_thing_line( [ delivery_party ] )
	
	, delivery_thing_line( [ delivery_street ] )

	, delivery_city_postcode_line
	  
] ).

%=======================================================================
i_line_rule( delivery_header_line, [ read_ahead( [ `lieferadresse`, `:` ] ), delivery_hook(s1) ] ).
%=======================================================================
i_line_rule( delivery_thing_line( [ Variable ] ), [ 
%=======================================================================

	  nearest( delivery_hook(start), 10, 10 )
	  
	, Read_Var
	  
	, trace( [ String, Variable ] )
	
] ):-

	Read_Var =.. [ Variable, s1 ]
	, sys_string_atom( String, Variable )
.

%=======================================================================
i_line_rule( delivery_city_postcode_line, [ 
%=======================================================================
	
	  nearest( delivery_hook(start), 10, 10 )
	  
	, delivery_postcode(f( [ begin, q(dec,4,5), end ] ) )
	  
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

	  q(0,20,line), generic_horizontal_details( [ order_number, sf, [ q10( [ `Änderung`, `zur` ] ), `Bestellung` ] ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Unsere`, `Referenz`, `:` ], buyer_contact_x, s1 ] )
	  
	, check( buyer_contact_x = Con )
	
	, or( [ [ check( string_to_lower( Con, Con_L ) )
	
				, check( q_sys_sub_string( Con_L, _, _, `back office` ) )
				
				, buyer_dept( `0013803370` )
				
				, delivery_from_contact( `0013803370` )
				
			]
			
		, [ generic_horizontal_details( [ [ `Telefon`, `:` ], 150, buyer_ddi_x, s1, newline ] )
		
			, check( buyer_ddi_x = DDI_x )
			
			, check( string_string_replace( DDI_x, `+41`, `0`, DDI ) )

			, check( q_sys_sub_string(Con, SP, 1, ` `) )
			, check( i_user_check( gen_subtract, SP, 1, SP1 )  )
			, check( q_sys_sub_string(Con, 1, SP1, NAME1 ) )
			, check( i_user_check( gen_add, SP, 1, SP2 )  )
			, check( q_sys_sub_string(Con, SP2, _, NAME2 ) )
			, check( strcat_list( [ NAME2, ` `, NAME1 ], NAME ) )
		
			, buyer_contact( NAME )
			
			, delivery_contact( NAME )
			
			, buyer_ddi( DDI )
			
			, delivery_ddi( DDI )
			
		]
		
	] )
	 
] ).


%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Bestelldatum`, `:` ], invoice_date, date, newline ] )
	  
] ).

%=======================================================================
i_rule( get_totals, [ q0n(line), totals_line ] ).
%=======================================================================
i_line_rule( totals_line, [
%=======================================================================

	  `End`, `-`, `Betrag`, tab
	  
	, read_ahead( [ generic_item( [ total_net, Format, newline ] ) ] )
	
	, generic_item( [ total_invoice, Format, newline ] )

] ):-	i_user_data( apostrophed_number_format, Format ).

%=======================================================================
i_user_data( apostrophed_number_format, [
%=======================================================================

	  begin
	, q([dec,other_skip("'")],1,8)
	, q(other("."),1,1)
	, q(dec,2,2)
	, end

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
i_line_rule_cut( line_end_section_line, [ `Seite`, num(d) ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		or( [  line_invoice_rule
		
				, line_check_defect_line
			
				, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Bezeichnung`, newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `End`, `-`, `Betrag` ] ).
%=======================================================================
i_line_rule_cut( line_check_defect_line, [ q0n(anything), some(date), force_result( `defect` ), force_sub_result( `missed_line` ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_values_line
	 
	, line_descr_rule
	
	, or( [ [ q(0,2, [ line, peek_fails( line_check_line ) ] ), line_item_line ]
	
		, line_item( `Missing` )
		
	] )
	
	, or( [ peek_fails( test( need_price ) )
	
		, [ test( need_price ), q(0,12, [ line, peek_fails( line_check_line ) ] )
		
			, line_discounted_net_line, clear( need_price )
			
		]
		
		, [ test( need_price ), q( 0, 4, [ line, peek_fails( line_check_line ) ] )
		
			, line_odd_format_line, clear( need_price )
			
		]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_descr_rule, [
%=======================================================================
   
	  or( [ [ q10( line ), line_kontierung_descr_line ]
	  
		, [ line_descr_line ]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_kontierung_descr_line, [ `Kontierung`, `:`, tab, generic_item( [ line_descr, s1, newline ] ) ] ).
%=======================================================================
i_line_rule_cut( line_descr_line, [ generic_item( [ line_descr, s1, newline ] ) ] ).
%=======================================================================
i_line_rule_cut( line_check_line, [ q0n(anything), tab, some_date(date) ] ).
%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================
   
	  generic_item( [ line_order_line_number, d, q10( tab ) ] )
	  
	, q10( generic_item( [ some_item, s1, tab ] ) )
	
	, generic_item( [ line_original_order_date, date, tab ] )

	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, or( [ [ generic_item( [ line_unit_amount_x, Format, [ `/`, thing(s1), tab ] ] )
	
			, generic_item( [ line_net_amount, Format, newline ] )
			
		]
		
		, [ `/`, newline, set( need_price ) ]
		
	] )

] ):-	i_user_data( apostrophed_number_format, Format ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================
   
	  `Ihre`, or( [ `Materialnummer`, `Materialnr` ] ), `.`, tab
	  
	, generic_item( [ line_item, s1, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_discounted_net_line, [
%=======================================================================
   
	  `Nettowert`, `incl`, `Rab`
	  
	, qn0(anything), tab
	
	, generic_item( [ line_net_amount, Format, newline ] )

] ):-	i_user_data( apostrophed_number_format, Format ).

%=======================================================================
i_line_rule_cut( line_odd_format_line, [
%=======================================================================
   
	  `Bruttopreis`
	  
	, qn0(anything), tab
	
	, generic_item( [ line_net_amount, Format, newline ] )

] ):-	i_user_data( apostrophed_number_format, Format ).