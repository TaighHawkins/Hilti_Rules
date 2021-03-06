%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FR ThyssenKrupp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fr_thyssenkrupp, `27 February 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number_and_date
	
	, get_delivery_address
	
	, get_contacts
	
	, get_buyer_email

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
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10554269` ) ]	
				, suppliers_code_for_buyer( `11697124` )		
	] )

	, set( delivery_note_ref_no_failure )
	
	, type_of_supply( `01` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number_and_date, [ q(0,5,line), order_date_header_line, get_order_and_date_line ] ).
%=======================================================================
i_line_rule( order_date_header_line, [ `Commande`, `d`, `'`, `achats` ] ).
%=======================================================================
i_line_rule( get_order_and_date_line, [ 
%=======================================================================

	  order_number(sf), `du`, invoice_date(d)
	  
	, the_month(w)
	
	, check( i_user_check( convert_the_month, the_month, Num ) )
	
	, append( invoice_date( Num ), `/`, `/` )
	
	, append( invoice_date(d), ``, `` )
	
	, trace( [ `order number and date`, order_number, invoice_date ] )

] ).

%=======================================================================
i_user_check( convert_the_month, Month, Num )
%----------------------------------------
:-
%=======================================================================

	  string_to_lower( Month, Month_L )  
	, month_lookup( Month_L, Num )
.

month_lookup( `janvier`, `01` ).
month_lookup( `février`, `02` ).
month_lookup( `mars`, `03` ).
month_lookup( `avril`, `04` ).
month_lookup( `mai`, `05` ).
month_lookup( `juin`, `06` ).
month_lookup( `juillet`, `07` ).
month_lookup( `août`, `08` ).
month_lookup( `septembre`, `09` ).
month_lookup( `octobre`, `10` ).
month_lookup( `novembre`, `11` ).
month_lookup( `décembre`, `12` ).
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================	  
	  
	  q(0,30,line), delivery_header_line
	  
	, trace( [ `found header` ] )

	, q01( line ), delivery_postcode_line
	
] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`Adresse`,`de`, `livraison`, `:` , q10( tab )
	
	, q10( [
	
		q0n(word)
		
		, or( [ [ `6`, set( six ) ]
		
			, [ `8`, set(eight) ]
			
		] )
		
		, `Rue`, `de`, `Champfleur`
		
	] )
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_line, [ 
%=======================================================================

	  q0n(word), delivery_postcode_x( f( [ begin, q(dec,5,5), end ] ) )
	
	, trace( [ `delivery postcode`, delivery_postcode_x] )
	
	, check( delivery_postcode_x = Ref )
	
	, or( [ [ check( q_regexp_match( `^49007$`, Ref, _ ) )
	
			, wrap( delivery_note_reference( Ref ), `FRTHY`, Append )
			
		]
	
		, wrap( delivery_note_reference( Ref ), `FRTHY`, `` )
		
	] )

] ):-	
	( grammar_set( six )	->	Append = `-6`
		;	grammar_set( eight )	->	Append = `-8`
		;	Append = ``
	)
.

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [
%=======================================================================	  
	  
	  q(0,15,line), generic_horizontal_details( [ [ `Gestionnaire` ], buyer_contact, s1, gen_eof ] )
	  
	, check( buyer_contact = Con )
	
	, delivery_contact( Con )
	
] ).

%=======================================================================
i_line_rule( gestionnaire_line, [ `Gestionnaire` ] ).
%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	  q(0,15,line), gestionnaire_line
	 
	, q(0,2,line), generic_horizontal_details( [ [ `Mail`, `:` ], buyer_email, s1, gen_eof ] )

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
	  
	, `EUR`,  tab
	  
	, read_ahead( [ q0n(word)
	
		, or( [ `.`
		
			, [ `,`, set(reverse_punctuation_in_numbers) ]

		] )
		
		, dummy(f( [ q(dec,2,2) ] ) ), newline
		
	] )
		
	, read_ahead( [ total_net(d) ] )

	, total_invoice(d), newline
	
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

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Poste`, tab, `Article` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Montant`, `Total`, `HT` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	  line_invoice_line
	  
	, line_item_line
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  retab( [ -340, -250, 20, 110, 150, 250, 370 ] )

	, generic_item( [ line_order_line_number, d, tab ] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item( [ line_descr, s, tab ] )
	
	, generic_item( [ line_original_order_date, date, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item( [ line_quantity, d, tab ] )
		
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  q0n(word) 
	  
	, line_item( f( [ begin, q(dec,4,10), end ] ) )
	
	, trace( [ `line item`, line_item ] )

] ).