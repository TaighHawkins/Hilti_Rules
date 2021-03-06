%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT CONERGY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_conergy, `11 April 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date
	
	, get_due_date

	, get_delivery_details
	
	, get_buyer_contact
	
	, get_delivery_contact

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
	    , suppliers_code_for_buyer( `14322354` )                      %PROD
	]) ]

	, delivery_party( `CONERGY` )
	
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
	  
	  q(0,20,line), generic_horizontal_details( [ [ `Riferimento`, `Commessa`, `:` ], order_number, s1, newline ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,5,line), generic_vertical_details( [ [ `Data`, `ordine` ], `Data`, start, invoice_date, date, tab ] )
	  
] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================

	  q(0,5,line), generic_vertical_details( [ [ `Data`, `di`, `consegna` ], `Data`, end, due_date, date, newline ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ q0n(line), buyer_contact_line ] ).
%=======================================================================
i_line_rule( buyer_contact_line, [
%=======================================================================

	 `Persona`, `di`, `riferimento`, `:`, tab

	, q10( [ `Sig`, `.` ] )
	
	, buyer_contact(sf)
	
	, set( regexp_cross_word_boundaries )
	
	, buyer_ddi(f( [ begin, q(dec,8,12), end ] ) )
	
	, clear( regexp_cross_word_boundaries )
	
	, trace( [ `contact and ddi`, buyer_contact, buyer_ddi ] )

] ).

%=======================================================================
i_rule( get_delivery_contact, [ qn0(line), delivery_contact_line ] ).
%=======================================================================
i_line_rule( delivery_contact_line, [ 
%=======================================================================

	  `Autorizzazione`, `ordine`, `:`, tab
	  
	, read_ahead( [ word, delivery_contact(w) ] )
	
	, append( delivery_contact(w), ` `, `` )
	
	, trace( [ `delivery contact`, delivery_contact ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ q(0,15,line), delivery_address_line ] ).
%=======================================================================
i_line_rule( delivery_address_line, [
%=======================================================================

	 `Indirizzo`, `di`, `consegna`, `:`, tab
	 
	, delivery_street(sf), q10( `–` )
	  
	, delivery_postcode( f( [ begin, q(dec,5,5), end ] ) )
	
	, delivery_city(sf), `(`
	
	, delivery_state( f( [ begin, q(alpha,2,2), end ] ) ), `)`
	
	, trace( [ `delivery stuffs`, delivery_city, delivery_state, delivery_postcode ] )

] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line), line_header_line
	  
	, total_net( `0` )
	  
	, q0n( totals_line )
	
	, na_line
	
	, check( total_net = Net )
	
	, total_invoice( Net )
	  
] ).	  
	  
%=======================================================================
i_line_rule( na_line, [ nearest( total_hook(end), 30, 5 ), `#`, `N`, `/`, `A` ] ).
%=======================================================================
i_line_rule( totals_line, [
%=======================================================================

	  nearest( total_hook(end), 30, 5 )
	 
	, generic_item( [ total_to_add, d, tab ] )
	
	, check( sys_calculate_str_add( total_net, total_to_add, Net ) )
	
	, total_net( Net )

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

		  or( [ 
		
			  line_invoice_line

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Codice`, `materiale`, `Hilti`, q0n(anything), read_ahead( `ordine` ), total_hook(w)] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `#`, `N`, `/`, `A` ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_item, s1, tab ] )
	
	, generic_item( [ requested, d, tab ] )
	
	, generic_item( [ pieces, d, tab ] )
	
	, read_ahead( generic_item( [ line_quantity, d, tab ] ) )
	
	, generic_item( [ line_net_amount, d, tab ] )

	, generic_item( [ line_descr, s1, newline ] )
	
	, count_rule
	
	, with( invoice, due_date, Due )
	
	, line_original_order_date( Due )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).