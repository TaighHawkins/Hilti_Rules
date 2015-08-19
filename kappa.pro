%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - KAPPA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( kappa, `01 August 2014` ).

i_date_format( _ ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `AT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11205959` ) ]    %TEST
	    , suppliers_code_for_buyer( `10027498` )                      %PROD
	]) ]

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

	,[q0n(line), get_line_original_order_date]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	%,[q0n(line), get_invoice_totals ]

	, total_net(`0`)

	, total_invoice(`0`)

] ).


%=======================================================================
i_rule( get_invoice_lines, [
%=======================================================================
 
	or([ [ q0n(line), get_invoice_lines_one ]

	, [ q0n(line), get_invoice_lines_two ]

	, [ q0n(line), get_invoice_lines_three ]

	, [ q0n(line), get_invoice_lines_four ]

	, [ q0n(line), get_invoice_lines_five ]

	, [ q0n(line), get_invoice_lines_six ]

	])
	 
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  get_delivery_header_line

	, get_delivery_party_line

	, q10(get_delivery_dept_line)

	, q10(line)

	, get_delivery_street_line

	, get_delivery_postcode_city_line
	 
] ).

%=======================================================================
i_line_rule( get_delivery_header_line, [
%=======================================================================
 
	 `lieferadresse`, newline

	, trace([ `delivery header found ` ])

] ).

%=======================================================================
i_line_rule( get_delivery_party_line, [
%=======================================================================
 
	delivery_party(s1)

	, trace([ `delivery party`, delivery_party ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_dept_line, [
%=======================================================================
 
	delivery_dept(s1)

	, trace([ `delivery address line`, delivery_address_line ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_street_line, [
%=======================================================================
 
	delivery_street(s)

	, trace([ `delivery street`, delivery_street ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_postcode_city_line, [
%=======================================================================
 
	q10([`a`, `-`])

	, delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(w)

	, trace([ `delivery city`, delivery_city ])

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`Bearbeiter`, `:` 

	, buyer_contact(s1)

	, trace([ `buyer contact`, buyer_contact ])

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	`Telefon`, `:`, tab

	, `+`, `43`, buyer_ddi(`0`), `(`

	, append(buyer_ddi(d), ``, ``), `)`

	, append(buyer_ddi(d), ``, ``)

	, append(buyer_ddi(d), ``, ``) 

	, append(buyer_ddi(d), ``, ``)

	, trace([ `buyer ddi`, buyer_ddi ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	`Bestell`, `-`, `Nr`, `.`, `:`, tab

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================

	q0n(anything)

	,`Steyr`, `,`
	
	, invoice_date(date)

	, trace( [ `invoice date`, invoice_date] )

	, newline

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	q0n(line), total_net_line

	, q0n(line), total_vat_line

	, q0n(line), total_invoice_line

] ).

%=======================================================================
i_line_rule( total_net_line, [
%=======================================================================


	`Nettobetrag`, `:`, tab, `EUR`, tab

	, total_net(d), newline

	, trace( [ `total net`, total_net ] )

] ).

%=======================================================================
i_line_rule( total_vat_line, [
%=======================================================================


	`MWST`, `20`, `,`, `0`, `%`, tab, `EUR`, tab

	, total_vat(d), newline

	, trace( [ `total vat`, total_vat ] )

] ).

%=======================================================================
i_line_rule( total_invoice_line, [
%=======================================================================

	`Gesamtbetrag`, `:`, tab, `EUR`, tab

	, total_invoice(d), newline

	, trace( [ `total invoice`, total_invoice ] )	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( get_invoice_lines_one, [
%=======================================================================

	 line_header_line_one

	, qn0( [ peek_fails(line_end_line_one)

		, or([ get_invoice_line_one, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line_one, [ `Bezeichnungen`, tab, `Artikelnummer`, tab, `Stk`, `.`,  newline ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line_one, [
%=======================================================================

	`Preise`, `gem`, `.`, `Ihrem`, `Angebot`

] ).

%=======================================================================
i_line_rule( get_invoice_line_one, [
%=======================================================================

	line_descr(s1), tab

	, trace([`line descr`, line_descr ])

	, set( regexp_cross_word_boundaries )

	, line_item(s1), tab

	, trace([`line item`, line_item ])

	, clear( regexp_cross_word_boundaries )

	, line_quantity(d)

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(`stk`)

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, newline

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES TWO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( get_invoice_lines_two, [
%=======================================================================

	 line_header_line_two

	, qn0( [ peek_fails(line_end_line_two)

		, or([ get_invoice_line_two, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line_two, [ `material`, `:`, newline] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line_two, [
%=======================================================================

	`Nettobetrag`, `:`, tab, `EUR`

] ).

%=======================================================================
i_line_rule( get_invoice_line_two, [
%=======================================================================

	line_descr(s1), tab

	, trace([`line descr`, line_descr ])

	,set( regexp_cross_word_boundaries )

	, or([ [ line_item(s1), tab], line_item(`Missing`) ])

	, trace([`line item`, line_item ])

	, clear( regexp_cross_word_boundaries )

	, line_quantity(d)

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(s)

	, trace([`line quantity oum code`, line_quantity_oum_code ])

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, newline

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES THREE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( get_invoice_lines_three, [
%=======================================================================

	 line_header_line_three

	, peek_fails(correct_section_line)

	, qn0( [ peek_fails(line_end_line_three)

		, or([ get_invoice_line_three, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line_three, [ or([ [ or([`Montagematerial`, `material`]), `wie`, `folgt`, `aufgelistet`, `:`,  newline], [ `Montagematerial`,  newline] ]) ]).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line_three, [
%=======================================================================

	`Nettobetrag`, `:`, tab, `EUR`

] ).

%=======================================================================
i_line_rule_cut( correct_section_line, [
%=======================================================================

	or([ `bezeichnung`, `bezeichnungen` ])

] ).

%=======================================================================
i_line_rule( get_invoice_line_three, [
%=======================================================================

	line_descr(s), tab

	, trace([`line descr`, line_descr ])

	,set( regexp_cross_word_boundaries )

	, or([ [ line_item(s1), tab], line_item(`Missing`)  ])

	, trace([`line item`, line_item ])

	,clear( regexp_cross_word_boundaries )

	, line_quantity(d), q10(tab)

	, trace([`line quantity`, line_quantity ])

	, or([ [ line_quantity_uom_code(s), `.`], line_quantity_uom_code(s) ])

	, trace([`line quantity oum code`, line_quantity_oum_code ])

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, newline

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES FOUR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( get_invoice_lines_four, [
%=======================================================================

	 line_header_line_four

	, qn0( [ peek_fails(line_end_line_four)

		, or([ get_invoice_line_four, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line_four, [ `Bezeichnung`, tab, `Artikel`, tab, `Stk`, q01(`.`),  newline] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line_four, [
%=======================================================================

	`Nettobetrag`, `:`, tab, `EUR`

] ).

%=======================================================================
i_line_rule( get_invoice_line_four, [
%=======================================================================

	line_descr(s1), tab

	, trace([`line descr`, line_descr ])

	,set( regexp_cross_word_boundaries )


	, or([ [ line_item(s1), tab] ,line_item(`Missing`) ])

	, trace([`line item`, line_item ])

	,clear( regexp_cross_word_boundaries )


	, line_quantity(d)

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(`stk`)

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, newline

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES FIVE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( get_invoice_lines_five, [
%=======================================================================

	 line_header_line_five

	, qn0( [ peek_fails(line_end_line_five)

		, or([ get_invoice_line_five, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line_five, [ 
%=======================================================================

	or( [ [ `mit`, `der`, `Auslegung`, `,`, `Herstellung`, `und`, `Lieferung` ]
	
		, [`mit`, `der`, `Lieferung`, `folgender`, `Positionen`, `:`,  newline ] 
		
		, [ `Pos`, q01( tab ), `Artikel`, tab ]
		
	] )
		
] ).



%=======================================================================
i_line_rule_cut( line_end_line_five, [
%=======================================================================

	`Nettobetrag`, `:`, tab, `EUR`

] ).

%=======================================================================
i_rule_cut( get_invoice_line_five, [
%=======================================================================

	get_values_line_five

	, get_descr_line_five

	, get_item_line_five

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_line_rule( get_values_line_five, [
%=======================================================================

	line_order_number_line(d)

	, trace([`line order number line`, line_order_number_line ])

	, num(d), tab

	, line_quantity(d)

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(w)

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, tab, unitamount(d), or([ tab , rabbat(d) ]), vat(d), tab

	, line_net_amount_x(d)

	, trace([`line net amount`, line_net_amount ])

	, q10([ with( invoice, due_date, DATE )

	, line_original_order_date( DATE ) ])

	, newline



] ).

%=======================================================================
i_line_rule_cut( get_descr_line_five, [
%=======================================================================

	line_descr(s1), q01([ tab, num(d), q10( word )]), newline

	, trace([`line descr`, line_descr ])

] ).


%=======================================================================
i_line_rule_cut( get_item_line_five, [
%=======================================================================
	
	q0n(anything)
	
	, q10( [
	
		or( [`artikel`
		
			, [`art`, `.`, `-`, `nr`, `.`]
			
			,[`art`, `.`,`nr`, `.`, `:`]
			
			, [`art`, `.`, `nr`, `.` ] 
			
			, [ `Ihre`, `Artikelnummer` `:` ]
			
		] ) 
		
	] )

	,set( regexp_cross_word_boundaries )

	, line_item(s1)

	, clear( regexp_cross_word_boundaries )

	,newline

	, trace([`line item`, line_item ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES SIX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( get_invoice_lines_six, [
%=======================================================================

	 line_header_line_six

	, qn0( [ peek_fails(line_end_line_six)

		, or([ get_invoice_line_six, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line_six, [ 
%=======================================================================

	or([ [`wie`, `folgt`, `:`, newline], [ `in`, `der`, `letztgültigen`, `Fassung`, `mit`, `der`, `Lieferung`, `folgender`, `Positionen`, `:`,  newline] ])


] ).


%=======================================================================
i_line_rule_cut( line_end_line_six, [
%=======================================================================

	`Nettobetrag`, `:`, tab, `EUR`

] ).

%=======================================================================
i_rule_cut( get_invoice_line_six, [
%=======================================================================

	get_values_line_six

	, q10([ read_ahead( artikel_line ) ])

	, get_descr_line_six

	, q10([ peek_fails(test(item_found)), get_item_line_six ])

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)


] ).

%=======================================================================
i_line_rule_cut( artikel_line, [
%=======================================================================

	q0n(anything), `artikel`, line_item(w), set(item_found)

] ).

%=======================================================================
i_line_rule( get_values_line_six, [
%=======================================================================

	line_order_number_line(d)

	, trace([`line order number line`, line_order_number_line ])

	, num(d), tab

	, line_quantity(d)

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(w)

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, tab, unitamount(d), tab

	, vat(d), tab

	, line_net_amount_x(d)

	, trace([`line net amount`, line_net_amount ])

	, q10([ with( invoice, due_date, DATE )

	, line_original_order_date( DATE ) ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( get_descr_line_six, [
%=======================================================================

	line_descr(s1), newline

	, trace([`line descr`, line_descr ])

] ).


%=======================================================================
i_line_rule_cut( get_item_line_six, [
%=======================================================================

	set( regexp_cross_word_boundaries )

	, line_item(s1)

	,clear( regexp_cross_word_boundaries )

	, check(line_item(start) < -300)

	, newline

	, trace([`line item`, line_item ])

] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LINE ORIGINAL ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_line_original_order_date, [ 
%=======================================================================

	get_line_original_order_date_header

	, get_line_original_order_date_line

] ).

%=======================================================================
i_line_rule( get_line_original_order_date_header, [ 
%=======================================================================

	`LIEFERTERMIN`,  newline

	, trace( [ `line original order date header found` ] ) 

] ).

%=======================================================================
i_line_rule( get_line_original_order_date_line, [ 
%=======================================================================

	q0n(anything)

	, due_date(date)

	, trace( [ `line original order date`, line_original_order_date ] ) 

] ).
