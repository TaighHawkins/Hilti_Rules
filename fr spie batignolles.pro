%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FR SPIE BATIGNOLLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fr_spie_batignolles, `21 January 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ get_fixed_variables, check_for_regularisation ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_regularisation, [ 
%=======================================================================

	  q0n(line), read_ahead( generic_line( [ [ `Observations`, `:` ] ] ) )
	
	, or( [ q(0,2,line), q(0,2,up) ] ), check_for_regularisation_line 
	
] ).

%=======================================================================
i_line_rule( check_for_regularisation_line, [
%=======================================================================

	  q0n(anything)

	, or( [ `REGUL`
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

	  get_format
	
	, get_order_number
	
	, get_order_date
	
	, get_due_date
	
	, get_delivery_address
	
	, get_contacts

	, get_html_invoice_lines, get_pdf_invoice_lines

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

	, type_of_supply( `01` )

	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Spie Batignolles` )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET FORMAT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_format, [
%=======================================================================

	  or( [
	
		[ q10(line), generic_line( [ [ `BON`, `DE`, `COMMANDE`, newline ] ] ), set( pdf ), trace( [ `PDF FORMAT` ] ) ]
		
		, [ set( html ), trace( [ `HTML FORMAT` ] ) ]
		
	] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Imputation`, `:` ], order_number_y, s1 ] )
	
	, q(0,5,line)
	
	, generic_horizontal_details( [ [ or( [ `Commande`, `Ordre` ] ), `d`, `'`, or( [ `achat`, `approvisionnement` ] ), `n`, `°` ]
		, order_number, s1 
	] )

	, check( order_number_y = Y )
	, append( order_number( Y ), ` `, `` )
	
] ):- grammar_set( html ).

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Commande`, `d`, `'`, `achat`, `n`, `°` ], order_number, s1 ] )
	
] ):- grammar_set( pdf ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ at_start, `Le` ], invoice_date, date ] )

] ).
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_due_date, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Pour`, `Le` ], due_date, date ] )

] ).
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [
%=======================================================================	  
	  
	  q(0,30,line), generic_horizontal_details( [ [ `Commandé`, `par` ], buyer_contact, s1 ] )
	
	, q10( [ test( pdf ), check( buyer_contact = Contact ), delivery_contact( Contact ), trace( [ `delivery_contact`, delivery_contact ] ) ] )

] ).
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ [ `Adresse`, `de`, `livraison` ] ] )
	  
	, delivery_thing( [ delivery_party ] )
	
	, q10( [ test( pdf ), line ] )
	
	, q( 1, 2, delivery_thing( [ delivery_street ] ) )
	
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 20 ] ) )
	
	, delivery_postcode_and_city_line
	
] ).

%=======================================================================
i_rule( delivery_thing( [ Var ] ), [ qn0( gen_line_nothing_here( [ generic_hook(start), 10, 20 ] ) ), delivery_thing_line( [ Var ] ) ] ).
%=======================================================================
i_line_rule( delivery_thing_line( [ Var ] ), [ nearest( generic_hook(start), 10, 20 ), generic_item( [ Var, s1 ] ) ] ).
%=======================================================================

%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================	  

	  nearest( generic_hook(start), 10, 20 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )
	
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

	  `Total`, `HT`
	
	, or( [
	
		[ `(`, `Euros`, `)` ]
		
		, [ `en`, tab ]
		
	] )

	, `:`,  tab
	
	, q01( [ set( regexp_cross_word_boundaries ), trace( [ `set regexp_cross_word_boundaries` ] ) ] )

	, read_ahead( [ total_net(d) ] )

	, total_invoice(d)
	
	, trace( [ `total_invoice`, total_invoice ] )
	
	, or( [
	
		[ test( pdf ), newline ]
		
		, test( html )
		
	] )
	
	, clear( regexp_cross_word_boundaries )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET HTML LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_html_invoice_lines, [
%=======================================================================

	  line_html_header_line
	 
	, q0n(
		or( [ line_html_order_rule
		
			, line
		] )
	)

	, line_html_end_line

] ):- grammar_set( html ).

%=======================================================================
i_line_rule_cut( line_html_header_line, [ read_ahead( `fournisseur` ), fournisseur(w), q10( tab ), `com`, tab ] ).
%=======================================================================
i_line_rule_cut( line_html_end_line, [ `Total`, `HT` ] ).
%=======================================================================
i_rule_cut( line_html_order_rule, [
%=======================================================================

	  line_html_order_line
	
	, or( [ peek_fails( test( no_descr ) )
	
		, [ test( no_descr ), up, up, generic_line( [ generic_item( [ line_descr, s1 ] ) ] )
			, line, clear( no_descr )
		]
		
	] )

] ).


%=======================================================================
i_line_rule_cut( line_html_order_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
	  
	, q10( generic_item( [ some_code, w, [ tab, check( some_code(end) < fournisseur(start) ) ] ] ) )

	, xor( [ generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ], q10( tab ) ] ), line_item( `Missing` ) ] )
	
	, num(d), word, q10( tab )
	
	, or( [ generic_item( [ line_descr, s1, tab ] ), set( no_descr ) ] )
	
	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )

	, generic_item( [ line_net_amount, d, newline ] )
	
	, q10( [ with( invoice, due_date, Date )
		, line_original_order_date( Date )
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET PDF LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_pdf_invoice_lines, [
%=======================================================================

	  line_pdf_header_line
	 
	, q0n(
		or( [ line_pdf_order_rule
		
			, line
		] )
	)

	, line_pdf_end_line

] ):- grammar_set( pdf ).

%=======================================================================
i_line_rule_cut( line_pdf_header_line, [
%=======================================================================

	  `fournisseur`, tab, `Com`, tab

] ).

%=======================================================================
i_line_rule_cut( line_pdf_end_line, [
%=======================================================================

	  `Total`, `HT`
	
] ).

%=======================================================================
i_rule_cut( line_pdf_order_rule, [
%=======================================================================

	  line_pdf_order_line

] ).

%=======================================================================
i_line_rule_cut( line_pdf_order_line, [
%=======================================================================

	  generic_item( [ line_item, s1, tab ] )
	
	, a(d), tab
	
	, word, q10(tab)
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, line_quantity(d), tab
	
	, generic_item( [ line_quantity_uom_code, w, q10(tab) ] )
	
	, q01( [ set( regexp_cross_word_boundaries ), trace( [ `set regexp_cross_word_boundaries` ] ) ] )
	
	, line_unit_amount(d), tab
	
	, generic_item( [ line_net_amount, d, newline ] )
	
	, with( invoice, due_date, Date ), line_original_order_date(Date)
	
	, clear( regexp_cross_word_boundaries )

] ).