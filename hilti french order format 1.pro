%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HILTI FRENCH ORDER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hilti_french_order, `20 February 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_pdf_parameter( x_tolerance_100, 100 ).

i_op_param( o_mail_subject, _, _, _, `WARNING: This document has NOT been processed - ship-to missing` )
:-
	result( _, invoice, force_sub_result, `missing_ship_to` ); data( invoice, force_sub_result, `missing_ship_to` )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_order_number
	, get_order_date
	
	, get_delivery_details
	
	, get_buyer_contact
	
	, gen_capture( [ [ `DATE`, `DE`, `LIVRAISON`, `:` ], due_date, date ] )

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
				, suppliers_code_for_buyer( `11716668` )		
	] )
	
	, or( [ [ test( test_flag ), delivery_note_number( `` ) ]	
				, delivery_note_number( `21329185` )		
	] )

	, sender_name( `Phibor Entreprises` )
	
	, type_of_supply(`01`)
	, set( reverse_punctuation_in_numbers )
	, set( leave_spaces_in_order_number )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	generic_horizontal_details( [ [ `CDE`, `:` ], order_number, s1, [ tab, `AV` ] ] )
	
	, q0n(line)
	
	, generic_horizontal_details( [ [ `Affaire`, `:`, append( order_number(s1), ` `, `` ), tab, `Acheteur` ] ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	q(0,5,line), generic_horizontal_details( [ [ `Le`, `:` ], invoice_date_x, s1 ] )
	
	, check( i_user_check( convert_the_month, invoice_date_x, Date ) )
	, invoice_date( Date )
	, trace( [ `Invoice Date`, Date ] )
	
] ).

%=======================================================================
i_user_check( convert_the_month, DateIn, DateOut )
%----------------------------------------
:-
%=======================================================================

	string_to_lower( DateIn, DateInL ),
	month_lookup( Month, Num ),
	trace( [ `Looking for `, Month ] ),
	q_sys_sub_string( DateInL, _, _, Month ),
	trace( `Found` ),
	string_string_replace( DateInL, Month, Num, DateOut )	
.

month_lookup( `janvier`, `01` ).
month_lookup( `jan`, `01` ).
month_lookup( `février`, `02` ).
month_lookup( `fév`, `02` ).
month_lookup( `fev`, `02` ).
month_lookup( `mars`, `03` ).
month_lookup( `mar`, `03` ).
month_lookup( `avril`, `04` ).
month_lookup( `avr`, `04` ).
month_lookup( `mai`, `05` ).
month_lookup( `juin`, `06` ).
month_lookup( `jun`, `06` ).
month_lookup( `juillet`, `07` ).
month_lookup( `jul`, `07` ).
month_lookup( `août`, `08` ).
month_lookup( `aoû`, `08` ).
month_lookup( `aou`, `08` ).
month_lookup( `septembre`, `09` ).
month_lookup( `sep`, `09` ).
month_lookup( `octobre`, `10` ).
month_lookup( `oct`, `10` ).
month_lookup( `novembre`, `11` ).
month_lookup( `nov`, `11` ).
month_lookup( `décembre`, `12` ).
month_lookup( `déc`, `12` ).
month_lookup( `dec`, `12` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================	  
	  
	  q0n(line), generic_line( [ [ `ADRESSE`, `DE`, `LIVRAISON` ] ] )
	
	, read_ahead( [ generic_horizontal_details( [ at_start, delivery_party, s1 ] )	
		, q10( delivery_party_append )
	] )
	
	, read_ahead( gen1_parse_text_rule_cut )
	
	, q(0,7,line), delivery_postcode_and_city_line
	
	, check( i_user_check( use_address_lookup, captured_text, delivery_postcode, DNN, Con, Number ) )
	
	, delivery_note_number( DNN )
	, trace( [ `Delivery Note Number`, DNN ] )
	
	, or( [ [ delivery_contact( Con )
			, delivery_ddi( Number )
			
			, trace( [ `Delivery Contact`, Con ] )
			, trace( [ `Delivery DDI`, Number ] )
		]
		
		, [ trace( [ `Unable to locate contact info` ] )
		
		]
		
	] )
			
	, q10( [ check( DNN = `` )
			, trace( [ `Lookup failed` ] )
			, force_result( `failed` )
			, force_sub_result( `missing_ship_to` )
	] )
	
] ).

%=======================================================================
i_rule_cut( gen1_parse_text_rule_cut, [ gen1_parse_text_rule( [ -500, -100, generic_line( [ [ `Date`, `de` ] ] ) ] ) ] ).
%=======================================================================	
i_line_rule_cut( delivery_party_append, [
%=======================================================================	  
	  
	  read_ahead( [ q0n(word), `ENTREPRISES`, gen_eof ] )
	
	, append( delivery_party(s1), ` `, `` )
	
] ).

%=======================================================================
i_line_rule( delivery_contact_line, [
%=======================================================================	  
	  
	  generic_item( [ delivery_contact_x, sf
		, [ 
			q(4,4, [ a(d), q10( `.` ) ] )
			, check( delivery_contact_x = CONT1 )
			, check( i_user_check( turn_surname_to_upper_case, CONT1, CONT ) )
		]
	] )
	
	, delivery_contact(CONT), trace( [ `delivery_contact`, delivery_contact ] )
	
] ).

%=======================================================================
i_user_check( use_address_lookup, ParaIn, PC, DNN, Con, Number )
%=======================================================================	  
:- 
	string_to_upper( ParaIn, ParaU ),
	trace( para( ParaIn ) ),
	
	( address_lookup( Street, PC, DNN ),
		q_sys_sub_string( ParaU, _, _, Street ),
		trace( `Found DNN` )
		
		;	q_sys_sub_string( PC, 1, 2, PCStart ),
			address_lookup( Street, PCLookup, DNN),
			q_sys_sub_string( PCLookup, 1, 2, PCLookupStart ),
			PCStart = PCLookupStart,
			trace( [ `Matched PC, need Street:`, Street ] ),
			q_sys_sub_string( ParaU, _, _, Street ),
			trace( `Found DNN from start of PC` )
		
		;	DNN = ``
	),

	!,
	
	( strip_string2_from_string1( ParaU, `:`, ParaStrip ),
		sys_string_split( ParaStrip, ` `, ParaList ),
		trace( paralist( ParaList ) ),
		
		( sys_append( _, [ `MR`, Name, Number | _ ], ParaList ),
			q_regexp_match( `^(\\d{2}\\.?){5}$`, Number, _ ),
			strcat_list( [ `MR `, Name ], Con )
			
			;	sys_append( _, [ FirstName, SurName, Number | _ ], ParaList ),
				q_regexp_match( `^(\\d{2}\\.?){5}$`, Number, _ ),
				strcat_list( [ FirstName, ` `, SurName ], Con )
				
			;	trace( `Trying to find Con` ),
				sys_append( _, [ FirstName, SurName, Num1, Num2, Num3, Num4, Num5 | _ ], ParaList ),
				trace( names( FirstName, SurName ) ),
				wordcat( [ Num1, Num2, Num3, Num4, Num5 ], Number ),
				trace( number( Number ) ),
				q_regexp_match( `^(\\d{2}[ \\.]?){5}$`, Number, _ ),			
				strcat_list( [ FirstName, ` `, SurName ], Con )
		)		
		
		;	true
	)
.

i_trace_lists.

%=======================================================================
i_user_check( turn_surname_to_upper_case, NamesIn, NamesOut )
%=======================================================================	  
:- 
	sys_string_split( NamesIn, ` `, Names ),
	sys_reverse( Names, [ Surname | ForeNames ] ),
	string_to_upper( Surname, SurnameUpper ),
	string_string_replace( NamesIn, Surname, SurnameUpper, NamesOut )
.

%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================	  
	  
	  generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [
%=======================================================================

	  q0n(line)
	
	, generic_horizontal_details( [ [ `Acheteur`, `:` ], buyer_contact, s1 ] )
	
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
i_line_rule_cut( line_header_line, [ `LIGNE`, `ARTICLE`, tab, `DATE` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`MONTANT`, `GLOBAL`, `HORS`
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	  line_invoice_line
	  
	, generic_line( [ generic_item( [ line_descr, s1, newline ] ) ] )
	
	, q10( [ with( invoice, due_date, Date )
		, line_original_order_date( Date )
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )

	, q10( or( [ [ `HLT`, `.` ]
			, [ q0n(word) ]
		] )
	)
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	
	, generic_item( [ some_date, date, tab ] )
	
	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item_cut( [ line_unit_amount, d, tab ] )
	, generic_item( [ line_net_amount, d, newline ] )
	
	, q10( [ check( q_sys_comp_str_eq( line_net_amount, `0` ) )
		, line_type( `ignore` )
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

	  q0n(line)
	  
	, generic_horizontal_details( [ [ `Montant`, `global`, dummy(s1), q01( [ tab, dummy(s1) ] ) ], 500, total_net, d ] )

	, check( total_net = Net )
	
	, total_invoice( Net )

] ).