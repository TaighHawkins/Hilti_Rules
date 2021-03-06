%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT CESARE FUMAGALLI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_cesare_fumagalli, `20 March 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_user_field( invoice, due_date_year, `due date year storage` ).

i_rules_file( `d_hilti_it_postcode.pro` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_contacts
	
	, get_due_date
	
	, get_shipping_instructions
	
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

	, buyer_registration_number( `IT-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10658906` ) ]    %TEST
	    , suppliers_code_for_buyer( `13045554` )                      %PROD
	]) ]
	
	, delivery_party( `CESARE FUMAGALLI SPA` )

	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,5,line), order_number_header_line
	  
	, order_number_part_one_line
	
	, q(0,20,line), order_number_part_two_line
	
	, order_number_part_three_line
	
	, trace( [ `order number`, order_number ] )
	
] ).

%=======================================================================
i_line_rule( order_number_header_line, [ `Data`, tab, `Numero` ] ).
%=======================================================================
i_line_rule( order_number_part_one_line, [
%=======================================================================
	  
	  q0n(word)
	  
	, year(f( [ q(dec,4,4) ] ) )
	
	, tab
	
	, order_number(w), tab
	
	, append( order_number(w), `-`, `` )
	
] ).

%=======================================================================
i_line_rule( order_number_part_two_line, [
%=======================================================================
	  
	  qn0(anything), tab
	  
	, `Commessa`, `:`, append( order_number(s1), `-`, `` ), newline
	
] ).

%=======================================================================
i_line_rule( order_number_part_three_line, [
%=======================================================================
	  
	  qn0(anything), tab
	  
	, `Parte`, `:`, append( order_number(w), `-`, `` )
	
] ).

%=======================================================================
i_rule( get_order_date, [ q(0,5,line), order_number_header_line, order_date_line ] ).
%=======================================================================
i_line_rule( order_date_line, [ generic_item( [ invoice_date, date, tab ] ) ] ).
%=======================================================================


%=======================================================================
i_rule( get_due_date, [
%=======================================================================

	  q(0,100,line), generic_horizontal_details( [ [ at_start, `Consegna`, `:`, q0n(word) ], due_date, date ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,10,line), generic_vertical_details( [ [ `NS`, `.`, `riferimento` ], `NS`, end, buyer_contact, s1, gen_eof ] )
	  
	, check( buyer_contact = Con )
	
	, delivery_contact( Con )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ q(0,30,line), delivery_details_line ] ).
%=======================================================================
i_line_rule( delivery_details_line, [
%=======================================================================

	  `Luogo`, `di`, `consegna`
	  
	, q0n(word), `commessa`, `:`
	
	, delivery_city(sf), `(`
	
	, delivery_state(sf), `)`
	
	, generic_item( [ delivery_street, s1, tab ] )
	
	, check( i_user_check( find_the_postcode, PC, delivery_city, delivery_state, Unknown ) )
	
	, delivery_postcode( PC )
	
	, trace( [ `delivery postcode from lookup`, delivery_postcode ] )

] ).

%=======================================================================
i_user_check( find_the_postcode, PC, City_L, State, Unknown )
%---------------------------------------
:-
%=======================================================================

	  string_to_upper( City_L, City )
	
	,(	postcode_lookup( PC, City, State, _ )
	
		;   postcode_lookup( PC, City, _, _ )
	
		;	PC = `Missing` 
	
	)
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [
%=======================================================================

	  q(0,30,line), generic_vertical_details( [ [ `Codice`, tab, `Descrizione` ], `Codice`, start, shipping_instructions, s1, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  qn0(line), read_ahead( generic_horizontal_details( [ [ `TOTALE`, q10( tab ), qn0(word) ], 200, total_net, d, newline ] ) )
	  
	, generic_horizontal_details( [ [ `TOTALE`, q10( tab ), qn0(word) ], 200, total_invoice, d, newline ] )

] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_section_end_line ).
%=======================================================================
i_line_rule( line_section_end_line, [ `Rif`, `.`, `R`, `.` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_line
			  
			, line_continuation_line

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Consegna`, `:` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Note`, newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_item, s1, tab ] )

	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
		
	, generic_item( [ line_quantity, d, tab ] )

	, generic_item( [ line_unit_amount, d, `q10`, tab ] )
	
	, generic_item( [ line_percent_discount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
	, with( invoice, due_date, Due )
	
	, line_original_order_date( Due )
	
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	  read_ahead( dummy(s1) )
	  
	, check( dummy(start) > -330 )
	
	, check( dummy(end) < 30 )
	
	, append( line_descr(s1), ` `, `` ), newline

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).