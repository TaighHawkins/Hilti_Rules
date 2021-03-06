%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FR LEONGROSSE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fr_leongrosse, `06 August 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables
	
	, check_for_regularisation 

	, get_order_date
	
	, get_order_number
	
] ).

%=======================================================================
i_rule( check_for_regularisation, [ 
%=======================================================================

	q0n(line), read_ahead( generic_line( [ [ `A`, `livrer`, `le`, `:` ] ] ) )
	
	, or( [ q(0,3,line), q(0,2,up) ] ), check_for_regularisation_line 
	
] ).

%=======================================================================
i_line_rule( check_for_regularisation_line, [
%=======================================================================

	q0n(anything)

	, or( [ `REGUL`
		, `régul`
		, `Regularisation`
		, `Régularisation`
	] )
	
	, trace( [ `Regularisation Rule Triggered - Order NOT being processed` ] )
	
	, delivery_note_reference( `special_rule` )
	, set( do_not_process )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_delivery_note_number
	
	, get_scfb

	, get_contacts

	, get_ddis
	
	, get_emails

	, get_invoice_lines

	, get_totals

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

	, set( delivery_note_ref_no_failure )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `BON`, `DE`, `COMMANDE`, or( [ `N°`, [ `N`, `°` ] ] ) ], order_number, s1 ] )
	  
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `,`, `le` ], invoice_date, date ] )

] ).

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_note_number, [ 
%=======================================================================

	  q(0,35,line), set( regexp_cross_word_boundaries )
	  
	, generic_horizontal_details( [ [ `Chantier`, `:` ], delivery_note_number_x, [ begin, q([dec,other_skip(".")],2,50), end ] ] )
	
	, clear( regexp_cross_word_boundaries )
	
	, check( delivery_note_number_x = X )
	
	, wrap( delivery_note_reference( `FRLEO` ), ``, X )
	
	, trace( [ `delivery note reference`, delivery_note_reference ] )
	
] ).
  
%=======================================================================
i_rule( get_scfb, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ read_ahead( [ `Adresse`, `de`, `facturation` ] ), dummy, s1 ] )
	  
	, q(4,1,line), generic_horizontal_details( [ suppliers_code_for_buyer_x, [ begin, q(dec,4,10), end ] ] )
	
	, check( suppliers_code_for_buyer_x(start) > -300 )
	
	, check( suppliers_code_for_buyer_x = X )
	
	, wrap( buyers_code_for_buyer( `FRLEO` ), ``, X )
	
	, trace( [ `buyers code for buyer`, buyers_code_for_buyer ] )
	
] ).
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [
%=======================================================================	  
	  
	  q0n(line), generic_vertical_details( [ [ `Affaire`, `suivie`, `par` ], `Affaire`, contacts, s1, tab ] )
	  
	, check( i_user_check( reverse_names, contacts, Con ) )

	, buyer_contact( Con )
	
	, delivery_contact( Con )
	
	, trace( [ `buyer contact`, buyer_contact ] )
	
] ).

%=======================================================================
i_user_check( reverse_names, Names_In, Con )
%-----------------------------------------------------------------------
:-
%=======================================================================
	sys_string_split( Names_In, ` `, [ Surname | Names ] ),
	string_to_upper( Surname, Surname_U ),
	sys_stringlist_concat( Names, ` `, First_Names ),
	strcat_list( [ First_Names, ` `, Surname_U ], Con )
.

%=======================================================================
i_rule( get_ddis, [
%=======================================================================	  
	  
	  q0n(line), generic_horizontal_details( [ [ `Portable`, `:` ], ddis, s1 ] )
	  
	, check( ddis = DDIs )
	
	, check( extract_pattern_from_back( DDIs, DDI, [ dec, dec, ` `, dec, dec, ` `, dec, dec, ` `, dec, dec, ` `, dec, dec ] ) )

	, buyer_ddi( DDI )
	
	, delivery_ddi( DDI )
	
	, trace( [ `buyer ddi`, buyer_ddi ] )
	
] ).

%=======================================================================
i_rule( get_emails, [
%=======================================================================	  
	  
	  q0n(line), generic_horizontal_details( [ [ `Email`, `:` ], buyer_email, s1, newline ] )
	  
	, check( buyer_email(end) < 0 )
	
	, check( buyer_email = Email )
	
	, delivery_email( Email )
	
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
	  
	, `MONTANT`, `HT`, `EUR`,  tab

	, set( regexp_cross_word_boundaries )
	, read_ahead( [ total_net(d) ] )

	, total_invoice(d), newline
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
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_rule
			  
			, line_continuation_line

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `d`, `'`, `achat`, `livraison`, tab ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `MONTANT`, `HT` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	  line_invoice_line

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, q10( tab ) ] )

	, generic_item( [ line_descr, s, q10( tab ) ] )
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	
	, set( regexp_cross_word_boundaries )
	
		, generic_item( [ line_quantity, d, tab ] )
	
	, clear( regexp_cross_word_boundaries )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item( [ line_original_order_date, date, tab ] )
	
	, set( regexp_cross_word_boundaries )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
	, clear( regexp_cross_word_boundaries )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).