%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - AT VOEST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( at_voest, `13 July 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( rules_for_everything, [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_bcfb
	
	, get_delivery_party
	
	, get_delivery_details

	, get_buyer_ddi
	
	, get_other_buyer_contact_and_ddi

	, get_buyer_email

	, get_order_date

	, get_order_number

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, [ qn0(line), invoice_total_line]

] ).

%		Because Sections go weird in labelled lists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ set( reverse_punctuation_in_numbers ), get_invoice_lines ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( reason_to_not_process, [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  [ without( delivery_note_reference ), delivery_note_reference( `Selbstabholung` ) ]
	  
	, chain_the_terms

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROCESSING CHECK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( rules_for_everything, [ peek_fails( reason_to_not_process ) ] ).
%=======================================================================
i_rule( reason_to_not_process, [ or( [ selbstabholung_rule, terms_lines_rule, fail_within_capture ] ) ] ).
%=======================================================================
i_rule( selbstabholung_rule, [ q0n(line), line_header_line_uncut, q(0,30,line), line_to_not_process ] ).
%=======================================================================
i_line_rule( line_to_not_process, [ q0n(anything), `Selbstabholung`, trace( [ `No processing!` ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( fail_within_capture, [ test( do_not_process ), delivery_note_reference( `leist` ), trace( [ `Failed from line level capture` ] ) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TERMS CHECK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( chain_the_terms, [ chain_the_terms_rule ] ).
%=======================================================================
i_rule( chain_the_terms_rule, [ terms_lines_rule, set( chain, `junk` ) ] ).
%=======================================================================
i_rule( terms_lines_rule, [ q(0,20,line), first_terms_line, q(0,10,line), second_terms_line ] ).
%=======================================================================
i_line_rule( first_terms_line, [ q0n(anything), `Intrastatmeldung`, `:` ] ).
%=======================================================================
i_line_rule( second_terms_line, [ q0n(anything), `begleitpapiere`, `:` ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

	  without( buyer_party )
	
	, set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `AT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, type_of_supply(`S0`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SCFB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_bcfb, [ 
%=======================================================================

	  without( buyers_code_for_buyer )
	  
	, q(0,20,line), generic_vertical_details( [ [ `Ihre`, `Partnernummer` ], `Ihre`, buyers_code_for_buyer, s1, gen_eof ] )

	, prepend( buyers_code_for_buyer( `ATVOE` ), ``, `` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  without( buyer_ddi )
	  
	, q(0,15,line), generic_horizontal_details( [ [ `Tel`, `.`, `:` ], ddi_x, s1, newline ] )
	
	, check( ddi_x = DDI_x )
	
	, check( string_string_replace( DDI_x, `(0043)`, `0`, DDI_y ) )
	
	, check( strip_string2_from_string1( DDI_y, `./() -`, DDI  ) )
	
	, buyer_ddi( DDI )
	
	, delivery_ddi( DDI )

] ).

%=======================================================================
i_rule( get_other_buyer_contact_and_ddi, [ 
%=======================================================================

	  without( buyer_ddi )
	  
	, q(0,15,line), generic_vertical_details( [ [ `AnsprechpartnerIn`, `/`, `Telefon` ], `AnsprechpartnerIn`, buyer_contact_x, s1, newline ] )
	  
	, generic_horizontal_details( [ buyer_ddi_x, s1, newline ] )

	, check( buyer_ddi_x = DDI_x )
	
	, check( string_string_replace( DDI_x, `+43`, `0`, DDI_y ) )
	
	, check( strip_string2_from_string1( DDI_y, `./() -`, DDI  ) )
	
	, buyer_ddi( DDI )
	
	, delivery_ddi( DDI )

] ).

%=======================================================================
i_rule( get_buyer_email, [ q(0,20,line), buyer_email_line ] ).
%=======================================================================
i_line_rule( buyer_email_line, [ 
%=======================================================================

	read_ahead( [ q0n(word), `@` ] )
	
	, generic_item( [ buyer_email, s1, newline ] )
	
	, check( buyer_email = Email )
	
	, delivery_email( Email )
	
	, check( i_user_check( split_names, buyer_email, Con ) )
	
	, buyer_contact( Con )
	
	, delivery_contact( Con )

] ).

%=======================================================================
i_user_check( split_names, Email, Con )
%-----------------------------------------------------------------------
:-
%=======================================================================
	sys_string_split( Email, `@`, [ Names_dot | _ ] ),
	string_string_replace( Names_dot, `.`, ` `, Con )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ without( delivery_street ), q01(line), delivery_details_line ] ).
%=======================================================================
i_line_rule( delivery_details_line, [
%=======================================================================

	  q01( [ dummy(s1), tab ] )
	  
	, generic_item( [ delivery_street, sf, `,` ] )
	  
	, or( [ [ `Postfach`, num(d), `,`
	
			, generic_item( [ delivery_postcode, [ begin, q(dec,4,4), end ] ] )
	
			, generic_item( [ delivery_city, w, [ `/`, `Austria` ] ] )
			
		]
		
		, [ thing(f( [ q(alpha,1,1) ] ) ), `-`
		
			, generic_item( [ delivery_postcode, [ begin, q(dec,4,4), end ] ] )
			
			, generic_item( [ delivery_city, s1 ] )
			
		]
		
	] )

] ).

%=======================================================================
i_rule( get_delivery_party, [
%=======================================================================

	  without( delivery_party )
	  
	, q(0,2,line), generic_horizontal_details( [ delivery_party, s1 ] )
	  
	, check( delivery_party(end) < 0 )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  without( order_number )
	  
	, q(0,10,line), generic_vertical_details( [ Hook, Anchor, order_number, s, `/` ] )

] ):-
	i_user_data( order_number_hook, Hook )
	, i_user_data( order_number_anchor, Anchor )
.

%=======================================================================
i_user_data( order_number_hook, [ `Bukrs`, `/`, `Ekgrp` ] ).
%=======================================================================
i_user_data( order_number_hook, [ `Bestellnummer`, `/`, or( [ `Ekg`, `Ekgrp` ] ) ] ).
%=======================================================================
i_user_data( order_number_anchor, [ `Bukrs` ] ).
%=======================================================================
i_user_data( order_number_anchor, [ `Bestellnummer` ] ).
%=======================================================================

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  without( invoice_date )
	  
	, q(0,10,line), generic_horizontal_details( [ [ `/` ], invoice_date, date ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	  without( total_invoice )
	
	, `Gesamtnettowert`, `ohne`, `Mwst`, q01( tab ), `EUR`, tab

	, read_ahead(total_invoice(d))

	, total_net(d)

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
i_line_rule_cut( line_end_section_line, [ 
%=======================================================================

	or( [ [ `Rechnungslegung`, `an`, `:` ]
	
		, [ `Anlieferung`, `an`, `voestalpine` ]
		
		, [ `*`, `*`, `Es`, `gelten` ]
		
	] )

] ).


%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [ line_invoice_rule
		
			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, tab, `Material`] ).
%=======================================================================
i_line_rule( line_header_line_uncut, [ `Pos`, `.`, tab, `Material`] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Gesamtnettowert`, `ohne`, `Mwst` ] ).
%=======================================================================
i_line_rule_cut( line_underscore_line, [ `_`, `_`, `_` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_values_line
	  
	, or( [ [ test( date_needed )
			, line_date_line
			, line_item_line
		]
	
		, [ line_item_line
	
			, or( [ line_underscore_line, line_descr_line, other_descr_line ] )
			
		]
		
		, [ q10( gen_line_nothing_here( [ -250, 50, 50 ] ) ), q10( line_underscore_line ), other_descr_line
		
			, q(0,5, or( [ line_underscore_line, line_continuation_line ] ) )
		
			, line_item_line
			
		]
	
		, [ q10( gen_line_nothing_here( [ -250, 50, 50 ] ) ), q10( line_underscore_line ), other_descr_line

			, line_item( `Missing` )
			
		]
		
	] )
	
	, or( [ peek_fails( test( need_total ) )
	
		, [ test( need_total ), q(0,4, [ peek_fails( or( [ line_underscore_line, line_end_line, line_values_line ] ) ), line ] )
		
			, or( [ line_discounted_net_line
			
				, [ generic_line( [ `Rabatt` ] )
				
					, generic_line( [ [ qn0(anything), tab, generic_item( [ line_net_amount, d, newline ] ) ] ] )
					
				]
				
			] )
			
			, clear( need_total )
			
		]
		
	] )
	
	, q10( [ check( line_quantity_uom_code = `Leist` ), set( do_not_process ) ] )
	
	, clear( got_descr )
	, clear( date_needed )

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, tab ] )
	
	, q01( generic_item( [ line_item_for_buyer, sf, q10( tab ) ] ) )
	
	, or( [ generic_item( [ line_original_order_date, date, tab ] ), set( date_needed ) ] )
	
	, generic_item( [ line_quantity, d ] )
	
	, or( [ [ generic_item( [ line_quantity_uom_code, s1, tab ] )

			, or( [ [ generic_item( [ line_unit_amount_x, d, `/` ] )
			
					, generic_item( [ per, d, tab ] )
					
				]
				
				, generic_item( [ line_unit_amount_x, d, tab ] )
				
			] )
			
			, generic_item( [ line_net_amount, d, newline ] )
			
		]
		
		, [ generic_item( [ line_quantity_uom_code, s1, newline ] ), set( need_total ) ]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_discounted_net_line, [
%=======================================================================

	  `Nettowert`
	  
	, qn0(anything), tab
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [ 
%=======================================================================

	generic_item( [ line_descr_x, s, [ or( [ tab, `Art` ] ), check( line_descr_x(start) < -150 ) ] ] ) 
	
	, check( line_descr_x = Descr )
	
	, or( [ [ test( got_descr ), append( line_descr(Descr), ` `, `` ) ]
	  
		, [ peek_fails( test( got_descr ) ), line_descr( Descr ), set( got_descr ) ]
		
	] )
	
] ).


%=======================================================================
i_line_rule_cut( other_descr_line, [ 
%=======================================================================

	read_ahead( generic_item( [ line_descr_x, s1, [ q01( [ tab, line_descr_y(s1), set( got_extra ) ] ), newline, check( line_descr_x(start) < -150 ) ] ] ) )
	
	, check( line_descr_x = Descr_x )
	
	, or( [ [ test( got_extra ), check( line_descr_y = Descr_y )
			, check( strcat_list( [ Descr_x, ` `, Descr_y ], Descr ) )
		]
		
		, check( Descr = Descr_x )
		
	] )
		
	, or( [ [ test( got_descr ), append( line_descr(Descr), ` `, `` ) ]
	  
		, [ peek_fails( test( got_descr ) ), line_descr( Descr ), set( got_descr ) ]
		
	] )
	
	, clear( got_extra )
	
] ).

%=======================================================================
i_line_rule( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  or( [ [ test( got_descr ), q01( append( line_descr(s), ` `, `` ) ) ]
	  
		, [ peek_fails( test( got_descr ) ), q01( [ line_descr(s), set( got_descr ) ] ) ]
		
	] )

	, or( [ [ or( [ [ `Ihre`, `Materialnummer` ]
	  
				, [ `Art`, `.`, `Nr`, `.`, `:` ]
				
				, [ q01(word), `Art`, q(0,3,word), `Nr`, q(0,3,word) ]
				
				, [ `Nummer`, `:` ]
				
				, [ `Art`, q10( `.` ) ]
				
			] )
			
			, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
		]
		
		, [ generic_item( [ line_item, [ begin, q(dec,4,10), end ], `-` ] )
			, or( [ [ test( got_descr ), q10( append( line_descr(s), ` `, `` ) ) ]
	  
				, [ peek_fails( test( got_descr ) ), q10( [ line_descr(s), set( got_descr ) ] ) ]
			] )
		]
	] )

] ).

%=======================================================================
i_line_rule_cut( line_date_line, [
%=======================================================================

	  generic_item( [ line_descr, s1, tab ] )
	  
	, `Liefertermin`, generic_item( [ line_original_order_date, date ] )

] ).

