%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HEIDENBAUER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( heidenbauer, `27 November 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_page_split_rule_list( [ check_for_new_format ] ).

i_section( check_for_new_format, [ new_format_line, trace( [ `CHAINING TO NEW FORMAT` ] ) ] ).
i_line_rule( new_format_line, [ check_text( `Lf-TerminMengeEin` ), set( chain, `at heidenbauer` ), set( re_extract ) ] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

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

	,[q0n(line), get_suppliers_code_for_buyer]

	,[q0n(line), get_delivery_address]

	,[q0n(line), get_buyer_contact]

	,[q0n(line), get_buyer_ddi]

	,[q0n(line), get_buyer_email]

	,[q0n(line), get_order_number]

	,[q0n(line), get_order_date]

	,[q0n(line), get_due_date]

	,[q0n(line), get_customer_comments]

	,[q0n(line), get_shipping_instructions]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_invoice_lines_two

	, or([ [q0n(line), invoice_total_line], [total_invoice(`0`), total_net(`0`) ] ])
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_suppliers_code_for_buyer, [ 
%=======================================================================

	or([ [`Metallbau`, `Heidenbauer`, `GmbH`, `&`, `Co`, `KG`, 

	or([ [ test(test_flag), suppliers_code_for_buyer( `11205959` ) ]   %TEST
	    , suppliers_code_for_buyer( `10040856` ) ]) ]                  %PROD    

	,[`Heidenbauer`, `Industriebau`, `GmbH`

	, or([ [ test(test_flag), suppliers_code_for_buyer( `11205957` ) ] %TEST  
	    , suppliers_code_for_buyer( `16693225` ) ]) ] ])               %PROD

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	delivery_party_line

	 , delivery_postcode_city_street_line

] ).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	`Lieferadresse`, `:`, tab

	, delivery_party(s1)

	, newline

	, trace([ `delivery party`, delivery_party ])
	
]).

%=======================================================================
i_line_rule( delivery_postcode_city_street_line, [ 
%=======================================================================

	delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(sf), `,`

	, trace([ `delivery city`, delivery_city ])

	, delivery_street(sf)

	, trace([ `delivery street`, delivery_street ])

	, q10([ `,`, delivery_dept(s1), trace([ `delivery street`, delivery_street ]) ])

	, newline

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(anything)

	,`Sachbearb`, `:`, tab

	, buyer_contact(sf)

	, `/`

	, trace( [ `buyer contact`, buyer_contact ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(anything)

	,`tel`, `.`, `:`

	, `+`, `43`, `(`

	, buyer_ddi(sf), `)`

	, append(buyer_ddi(sf), ``, ``), `/`

	, append(buyer_ddi(s), ``, ``)

	, `fax`, `:`

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	q0n(anything)

	,`e`, `-`, `mail`, `:`, tab

	, buyer_email(s1)

	, newline

	, trace( [ `buyer email`, buyer_email ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	`Bestellung`, `Nr`, `.`, `:`, tab

	, order_number(s1)

	, newline

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================

	`Bruck`, `/`, `Mur`, `,`, `am`

	, invoice_date(date)

	, newline

	, trace( [ `invoice date`, invoice_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_due_date, [ 
%=======================================================================

	`liefertermin`, `:`, tab

	, due_date(date)

	, newline

	, trace( [ `due date`, due_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	customer_comments_header

	, customer_comments_line

	, customer_comments_line_two

] ).

%=======================================================================
i_line_rule( customer_comments_header, [ 
%=======================================================================

	`Bestellung`, `Nr`, `.`, `:`

	, trace( [ `customer comments header found` ] ) 

] ).

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	customer_comments(s1), tab

	, q10(append(customer_comments(s1), ` `, ``))

	, q10(tab)

	, q10(append(customer_comments(s1), ` `, ``))

	, newline

	, trace( [ `customer comments`, customer_comments ] ) 

] ).

%=======================================================================
i_line_rule( customer_comments_line_two, [ 
%=======================================================================

	append(customer_comments(s1), ` `, ``), tab

	, q10(append(customer_comments(s1), ` `, ``))

	, q10(tab)

	, q10(append(customer_comments(s1), ` `, ``))

	, newline

	, trace( [ `customer comments`, customer_comments ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [ 
%=======================================================================

	shipping_instructions_header

	, shipping_instructions_line

	, shipping_instructions_line_two

] ).

%=======================================================================
i_line_rule( shipping_instructions_header, [ 
%=======================================================================

	`Bestellung`, `Nr`, `.`, `:`

	, trace( [ `shipping instructions header found` ] ) 

] ).

%=======================================================================
i_line_rule( shipping_instructions_line, [ 
%=======================================================================

	shipping_instructions(s1), tab

	, q10(append(shipping_instructions(s1), ` `, ``))

	, q10(tab)

	, q10(append(shipping_instructions(s1), ` `, ``))

	, newline

	, trace( [ `shipping instructions`, shipping_instructions ] ) 

] ).

%=======================================================================
i_line_rule( shipping_instructions_line_two, [ 
%=======================================================================

	append(shipping_instructions(s1), ` `, ``), tab

	, q10(append(shipping_instructions(s1), ` `, ``))

	, q10(tab)

	, q10(append(shipping_instructions(s1), ` `, ``))

	, newline

	, trace( [ `shipping instructions`, shipping_instructions ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	`Zwischensumme`, tab

	, set( regexp_cross_word_boundaries )

	, read_ahead(total_invoice(d))

	, clear( regexp_cross_word_boundaries )	

	, set( regexp_cross_word_boundaries )

	, total_net(d)

	, clear( regexp_cross_word_boundaries )

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line
	 
	, set( first_done )
	
	, set( no_total_validation )

	, qn0( [ peek_fails(line_end_line)

		, or([ line_invoice_rule
		
			, line_defect_line 
			
			, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `ArtNr`, `/`, `Bez`, `.`, tab, `Farbe` ] ).
%=======================================================================
i_line_rule_cut( line_defect_line, [ `Pos`, tab, force_result( `defect` ), force_sub_result( `missed_line` ) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or([ [`Zwischensumme`, tab], [`Preise`, `:`] ])

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	or( [ [ line_values_line
	
			, q10( [ test( used_parent ), line ] )

			, line_descr_line
			
		]
		
		, [ line_descr_line
		
			, q01( generic_line( [ [ append( line_descr(s1), ` `, `` ), newline ] ] ) )
		
			, line_values_line
			
			, q10( [ test( used_parent ), line ] )
			
		]
		
	] )

	, clear( used_parent )
	
] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	  set( regexp_cross_word_boundaries )
	  
	, or( [ read_ahead( generic_item( [ line_item, [ q(alpha("H"),1,1), q(alpha("I"),1,1), begin, q([ alpha,dec],4,20), end ] ] ) )
	
		, line_item( `Missing` )
		
	] )

	, generic_item( [ line_item_for_buyer, s1, q10( tab ) ] )
	
	, clear( regexp_cross_word_boundaries )

	, or( [ line_value_rule
	
		, [ parent, line, line_value_rule_line, set( used_parent ) ]
		
		, [ newline ]
		
	] )

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

] ).

%=======================================================================
i_line_rule_cut( line_value_rule_line, [ line_value_rule ] ).
%=======================================================================
i_rule_cut( line_value_rule, [
%=======================================================================

	  q10( [ set( regexp_cross_word_boundaries )

		, generic_item( [ line_quantity, d, check( line_quantity(start) > -150 ) ] )

		, clear( regexp_cross_word_boundaries )

		, generic_item( [ line_quantity_uom_code, w, tab ] )

	] )

	, generic_item( [ preis, s1, [ tab, check( preis(start) > 140 ) ] ] )

	, set( regexp_cross_word_boundaries )

	, generic_item( [ line_net_amount, d, newline ] )

	, clear( regexp_cross_word_boundaries )

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	`pos`, tab

	, set( regexp_cross_word_boundaries )

	, num(d)

	, clear( regexp_cross_word_boundaries )

	, generic_item( [ line_descr, s1, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES TWO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section( get_invoice_lines_two, [
%=======================================================================

	 line_header_line_two

	, qn0( [ peek_fails(line_end_line)

		, or([ line_invoice_line_two, line_invoice_rule_three, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line_two, [ peek_fails( test( first_done ) ), `Kostenstelle`, `:`, tab ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_invoice_line_two , [
%=======================================================================

	line_quantity(d), tab

	, trace([ `line quantity`, line_quantity ])

	, line_quantity_uom_code(w), tab

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, line_descr(s1)

	, trace([ `line description`, line_descr ])

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, line_item(`Missing`)

	, newline

] ).

%=======================================================================
i_rule_cut( line_invoice_rule_three , [
%=======================================================================

	line_descr_line_three

	, line_values_line_three

] ).

%=======================================================================
i_line_rule_cut( line_descr_line_three, [
%=======================================================================

	line_descr(s1)

	, trace([ `line description`, line_descr ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( line_values_line_three, [
%=======================================================================

	line_quantity(d)

	, trace([ `line quantity`, line_quantity ])

	, line_quantity_uom_code(w)

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, line_item(`Missing`)

	, newline

] ).