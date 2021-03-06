%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FR GIENNOISE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fr_giennoise, `10 April 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_pdf_parameter( new_line, 15 ).
i_pdf_parameter( same_line, 10 ).
i_pdf_parameter( language, `french` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number_and_date

	, get_totals
	
	, check_for_modification

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK FOR MODIFICATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_modification, [ 
%=======================================================================

	q(0,50,line)
	
	, generic_horizontal_details( [ or( [ `Modifiée`, `modifiee`, `modifier`, `Modifié`, `modifie` ] ) ] )
	
	, set( do_not_process )
	, delivery_note_reference( `special_rule` )
	
	, trace( [ `Modification detected - document NOT processed` ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_contacts
	
	, get_buyer_email
	
	, get_buyer_ddi
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

] ):- not( grammar_set( do_not_process ) ).


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
				, suppliers_code_for_buyer( `11543891` )		
	] )
	
	, or( [ [ test( test_flag ), delivery_note_number( `10558391` ) ]	
				, delivery_note_number( `11543891` )		
	] )
	
	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number_and_date, [ q(0,15,line), order_and_date_line ] ).
%=======================================================================
i_line_rule( order_and_date_line, [ 
%=======================================================================

	  `Commande`, or( [ [ `N`, `°` ], `N`, `N°` ] )
	  
	, generic_item( [ order_number, s1, tab ] )
	
	, `Du`, generic_item( [ invoice_date,date, gen_eof ] )

] ).


  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [
%=======================================================================	  
	  
	  q(0,15,line), generic_horizontal_details( [ [ `Suivi`, `Par`, `:` ], buyer_contact, s1, gen_eof ] )
	  
	, check( buyer_contact = Con )
	
	, delivery_contact( Con )
	
] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `E`, `-`, `Mail`, `:` ], buyer_email, s1, gen_eof ] )
	  
	, check( buyer_email = Email )
	
	, delivery_email( Email )
	  
] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ or( [ [ `T`, `l`, `phone` ], `Téléphone` ] ), `:` ], buyer_ddi_x, s1, gen_eof ] )
	  
	, check( string_string_replace( buyer_ddi_x, `.`, ` `, DDI ) )
	
	, buyer_ddi( DDI )

	, delivery_ddi( DDI )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ q0n(line), totals_line ] ).
%=======================================================================
i_line_rule( totals_line, [
%=======================================================================

	  q0n(anything)
	  
	, `Total`, `H`, `.`, `T`, `.`,  tab
	
	, clear( reverse_punctuation_in_numbers )

	, set( regexp_cross_word_boundaries )
	
	, read_ahead( [ total_net(d) ] )

	, total_invoice(d), q10( word ), newline

	, clear( regexp_cross_word_boundaries )
	
	, trace( [ `total_invoice`, total_invoice ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	, set( reverse_punctuation_in_numbers )
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_section_rule

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ or( [ [ `R`, `f` ], `Réf` ] ), `.`, tab, or( [ [ `D`, `signation` ], `Désignation` ] ) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Mode`, `de`, or( [ [ `r`, `glement` ], `réglement` ] ) ] ).
%=======================================================================
i_rule_cut( line_invoice_section_rule, [ 
%=======================================================================

	  line_date_line
	  
	, qn0( line_invoice_rule )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	  line_invoice_line
	  
	, q01( line_continuation_line )
	
	, line_item_line
	
	, check( the_date = Date )
	
	, line_original_order_date( Date )
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_date_line, [
%=======================================================================

	  `Pour`, `le`, `:`, tab
	  
	, the_date(date), newline

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ trash, s1, tab ] )

	, generic_item( [ line_descr, s, tab ] )

	, set( regexp_cross_word_boundaries )
	
	, generic_item( [ line_quantity, d, tab ] )
		
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
	, clear( regexp_cross_word_boundaries )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  `Votre`, or( [ [ `r`, `f`, `rence` ], `référence` ] ), `:`
	  
	, line_item( f( [ begin, q(dec,4,10), end ] ) )
	
	, trace( [ `line item`, line_item ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).