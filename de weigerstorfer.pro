%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE WEIGERSTORFER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( weigerstorfer, `23 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_pdf_parameter( same_line, 8 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables
	  
	, get_order_number
	
	, get_order_date
	
	, get_due_date
	
	, get_totals

	, check_for_special_rules
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPECIAL RULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_special_rules, [
%=======================================================================	  
	  
	  q0n(line), line_header_line
	  
	, q0n(line)
	
	, or( [ generic_horizontal_details( [ [ set(regexp_allow_partial_matching) ], flotte
			, [ begin, q(alpha("F"),1,1), q(alpha("l"),1,1), q(alpha("o"),1,1), q(alpha("t"),2,2), q(alpha("e"),1,1), end ]
		] )
		
		, generic_horizontal_details( [ `Manuell` ] )
	] )
	
	, q0n(line), generic_line( [ [ `Hiermit`, `bestellen` ] ] )
	
	, delivery_note_reference( `special_rule` )
	, set( do_not_process )
	, trace( [ `Line level condition triggered - Document NOT processed` ] )

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_contact_information

	, get_customer_comments
	
	, get_shipping_instructions

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines
	
	, set( delivery_note_ref_no_failure )

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

	, buyer_registration_number( `DE-ADAPTRI` )

	, or( [ 
		[ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, or( [ 
		[ test(test_flag), suppliers_code_for_buyer( `10254350` ) ]    %TEST
	    , suppliers_code_for_buyer( `10254350` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Weigerstorfer GmbH` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,20,line), generic_horizontal_details( [ [ `Bestellung` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,30,line), generic_horizontal_details( [ gen_beof, invoice_date, date ] )
	
] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================	  
	  
	  q(0,30,line)
	  
	, generic_horizontal_details( [ [ `Liefertermin`, `:` ], due_date, date
		, or( [ gen_eof
			, [ set( do_not_process ), delivery_note_reference( `special_rule` ), trace( [ `Trash after Due Date - Document NOT processed` ] ) ]
		] ) 
	] )

	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contact_information, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ [ `Unser`, `Zeichen`, q0n(word), `-` ], buyer_contact, s1 ] )
	
	, generic_horizontal_details( [ [ `Tel`, `:` ], buyer_ddi_x, s1 ] )
	, check( strip_string2_from_string1( buyer_ddi_x, `-/ `, DDI ) )
	, buyer_ddi( DDI )
	
	, generic_horizontal_details( [ [ `email`, `:` ], buyer_email, s1 ] )
	, check( buyer_email = Email )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	  q(0,20,line)
	  
	, generic_horizontal_details( [ [ tab, read_ahead( `Kommission` ) ], customer_comments, s1 ] )
	
	, check( customer_comments(start) = StartPlusFive )
	, check( sys_calculate( Start, StartPlusFive - 5 ) )
	
	, qn0( gen_line_nothing_here( [ StartPlusFive, 10, 10 ] ) )
	
	, generic_line( 1, Start, 500, [ generic_item( [ delivery_note_reference_x, s1 ] ) ] )
	, check( delivery_note_reference_x = DNRx )
	, check( string_to_upper( DNRx, DNR ) )
	, delivery_note_reference( DNR )
	, prepend( delivery_note_reference( `DEWEIG` ), ``, `` )
	
	, append( customer_comments( DNRx ), `~`, `` )	
	
	, q0n(
		or( [ generic_line( 1, Start, 500, [ append( customer_comments(s1), `~`, `` ) ] )
			, gen_line_nothing_here( [ StartPlusFive, 10, 10 ] )
		] )
	)
	
	, generic_line( [ `Liefertermin` ] )

] ).

%=======================================================================
i_rule( get_shipping_instructions, [ 
%=======================================================================

	  q(0,20,line)
	  
	, generic_horizontal_details( [ [ `Lieferadresse`, `:`, tab, komm_hook(s1) ] ] )
	
	, check( komm_hook(start) = EndPlusFive )
	, check( sys_calculate( End, EndPlusFive - 5 ) )
	
	, check( generic_hook(start) = StartPlusFive )
	, check( sys_calculate( Start, StartPlusFive - 5 ) )
	
	, qn0( gen_line_nothing_here( [ StartPlusFive, 10, 10 ] ) )
	
	, generic_line( 1, Start, End, [ generic_item( [ shipping_instructions, s1 ] ) ] )
	
	, q0n(
		or( [ generic_line( 1, Start, End, [ append( shipping_instructions(s1), `~`, `` ) ] )
			, gen_line_nothing_here( [ StartPlusFive, 10, 10 ] )
		] )
	)
	
	, generic_line( [ `Liefertermin` ] )
	
	, q10( [ q(0,3,line), generic_line( [ [ `Bemerkung`, `:`, append( shipping_instructions(s1), `~`, `` ) ] ] )
		, q(0,3, generic_line( [ append( shipping_instructions(s1), `~`, `` ) ] ) )
		, generic_line( [ dummy(s1) ] ), check( dummy(font) = komm_hook(font) )
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	 total_net( `0` ), set( no_total_validation )	
	, check( total_net = Net )
	, total_invoice( Net )

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

	, q0n(

		or( [ 
		
			  line_invoice_rule
			  
			, line_defect_line

			, line

		] )

	), line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `lfd`, `.`, `Nr`, tab, read_ahead( `Menge` ), header(w), tab ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Hiermit`, `bestellen` ]
	
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
] ).

%=======================================================================
i_line_rule_cut( line_defect_line, [ q(2,2,[ dum(d), tab ] ), force_result( `defect` ), force_sub_result( `missed_line` ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, or( [ line_uom_line
	
		, [ test( need_number )
			, generic_line( [ generic_item( [ line_order_line_number, d, newline ] ) ] )
			
			, generic_line( [ [ generic_item( [ line_quantity_uom_code, w ] ), q10( [ tab, some(s1) ] ), newline ] ] )
		]
	] )
	
	, q10( [ with( invoice, due_date, Date )
		, line_original_order_date( Date )
	] )
	
	, clear( need_number )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  or( [ generic_item_cut( [ line_order_line_number, d, [ tab, check( line_order_line_number(end) < header(start) ) ] ] )
		, set( need_number )
	] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, or( [ generic_item( [ line_item, f( [ q([alpha("HI"),other("*")],0,6), begin, q(dec,4,10), end ] ), tab ] ), line_item( `Missing` ) ] )

	, generic_item( [ line_descr, s1, newline ] )

] ).
%=======================================================================
i_line_rule_cut( line_uom_line, [
%=======================================================================

	  or( [ peek_fails( test( need_number ) )
		, [ test( need_number )
			, generic_item_cut( [ line_order_line_number, d, [ tab, check( line_order_line_number(end) < header(start) ) ] ] )
		]
	] )
	, generic_item( [ line_quantity_uom_code, w ] )
	
	, q10( [ tab, some(s1) ] ), newline

] ).