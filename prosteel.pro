%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - PRO STEEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( pro_steel_test, `27 March 2015` ).

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
	    , suppliers_code_for_buyer( `10034058` )                      %PROD
	]) ]


	, [ or([ 
	  [ test(test_flag), delivery_note_number( `11205959` ) ]    %TEST
	    , delivery_note_number( `10034058` )                      %PROD
	]) ]


	, customer_comments( `` )
	, shipping_instructions( `` )

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

	,[q0n(line), get_buyer_contact ]

	,or([ [q0n(line), get_buyer_ddi_one ], [q0n(line), get_buyer_ddi_two ] ])

	,[q0n(line), get_buyer_email ]

	,[q0n(line), due_date_line ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, total_net(`0`)

	, total_vat(`0`)

	, total_invoice(`0`)


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything)

	,`Bestell`, `Nr`, `.`, `:`, tab

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_date, [ 
%=======================================================================

	`datum`, `:`, tab

	, invoice_date(date)

	, trace( [ `invoice date`, invoice_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`aussteller`, `:`, q10(tab(50)), or( [ `Hr`, `Fr` ] ), `.`

	, buyer_contact_x(s1)

	, trace([ `buyer contact`, buyer_contact_x ])

	, check( buyer_contact_x = Con_X )
	
	, check( string_to_upper( Con_X, Con_U ) )
	
	, check( strcat_list( [ `ATPROS`, Con_U ], Dept ) )
	
	, buyer_dept( Dept )

] ).

%=======================================================================
i_line_rule( get_buyer_ddi_one, [ 
%=======================================================================

	q0n(anything)

	,`t`, `.`

	, `+`, num(d), buyer_ddi(`0`)

	, append(buyer_ddi(w), ``, ``), `-`

	, append(buyer_ddi(w), ``, ``), `-`

	, append(buyer_ddi(w), ``, ``)

	, trace([ `buyer ddi`, buyer_ddi ])

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_ddi_two, [ 
%=======================================================================

	q0n(anything)

	,`tel`, `.`

	, buyer_ddi(w), `/`

	, append(buyer_ddi(w), ``, ``), `-`

	, append(buyer_ddi(w), ``, ``)

	, trace([ `buyer ddi`, buyer_ddi ])

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	q0n(anything)

	, or([ [`e`, `-`, `mail`, `:`], [`e`, `.`] ])

	, set( regexp_cross_word_boundaries )

	, buyer_email(s1)

	, trace([ `buyer email`, buyer_email ])

	, newline

	, clear( regexp_cross_word_boundaries )


] ).


%=======================================================================
i_line_rule( due_date_line, [ 
%=======================================================================

	q0n(anything)

	,`Liefertermin`, `:`, tab

	, due_date(date)

	, trace([ `due date`, due_date])

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

	, line

	, qn0( [ 
		    or([ get_invoice_line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `pos`, `.`,  q0n(anything), read_ahead(`abmessung`), abmessung(w), tab, norm(w)] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( get_invoice_line, [
%=======================================================================

	line_order_line_number_x(d), tab

	, trace([ `line order line number`, line_order_line_number_x ])

	, line_quantity(d), q10(tab)

	, trace([ `line quantity`, line_quantity ])

	, benennung(s), q10(tab)

	, check(benennung(end) < abmessung(start) )

	, trace([ `benennung found`, benennung ])

	, line_descr(s)

	, check(line_descr(end) < norm(start) )

	, trace([ `line description`, line_descr ])

	, q10([ or([ [q10(tab), line_item(w), q10(append(line_item(w), ``, ``))], line_item(`Missing`) ])

	, trace([ `line item`, line_item ]) ])

	, q10([ with( invoice, due_date, DATE )

		, line_original_order_date( DATE )

		, trace( [ `original order date set to`, line_original_order_date ] ) 
	])

	, line_quantity_uom_code(`Stk`)

	, q01([ tab, dummy(s1) ])

	, newline

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)


] ).
