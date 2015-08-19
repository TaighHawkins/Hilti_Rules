%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - LOHR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( lohr, `04 November 2014` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 get_fixed_variables

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), due_date_line ]
	
	, get_delivery_details

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
i_line_rule( get_fixed_variables, [ 
%=======================================================================

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )
	, supplier_party( `LS` )

	, buyer_registration_number( `AT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11205959` ) ]    %TEST
	    , suppliers_code_for_buyer( `10024598` )                      %PROD
	]) ]

	, customer_comments( `` )
	, shipping_instructions( `` )

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

	,`Bestellung`, tab

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_date, [ 
%=======================================================================

	q0n(anything)

	,`datum`, `:`, tab

	, invoice_date(date)

	, trace( [ `invoice date`, invoice_date ] ) 

	, newline

] ).

%=======================================================================
i_line_rule( due_date_line, [ 
%=======================================================================

	`lieferdatum`, `:`, tab

	, due_date(date)

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

	q0n(anything)

	, `sachbearbeiter`, `:`, tab

	, buyer_dept(s1)

	, prepend(buyer_dept(`ATLOHR`), ``, ``)

	, trace([ `buyer dept`, buyer_dept ])

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_thing( [ Var ] ), [ nearest( generic_hook(start), 10, 10 ), q10( `:` ), generic_item( [ Var, s1 ] ) ] ). 
%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	or( [ [ q(0,30,line), generic_horizontal_details( [ [ at_start, `Lieferadresse` ] ] )
	
			, delivery_thing( [ delivery_party ] )
			, delivery_thing( [ customer_comments ] )
			, delivery_thing( [ delivery_dept ] )
			, delivery_thing( [ delivery_street ] )
			, delivery_postcode_city_line
			
		]
		
		, delivery_note_number( `10024598` )
		
	] )

] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================

	nearest( generic_hook(start), 10, 10 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	, generic_item( [ delivery_city, s1 ] )

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

	, qn0( [ peek_fails(line_end_line)

		, or([ [ get_invoice_line, q10([peek_fails(line_end_line), line_continuation_line ]) ]

			, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `preis`, tab, `+`, `/`, `-`, `%`, tab, `preis` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`liefertermin`, `kw`, `:`

] ).

%=======================================================================
i_line_rule_cut( get_invoice_line, [
%=======================================================================

	line_quantity(d)

	, trace([ `line quantity`, line_quantity ])

	, line_quantity_uom_code(w), tab

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, line_item(s1), tab

	, trace([ `line item`, line_item ])

	, line_descr(s1)

	, trace([ `line description`, line_descr ])

	, q10([ with( invoice, due_date, DATE )

		, line_original_order_date( DATE )

		, trace( [ `original order date set to`, line_original_order_date ] ) ])

	, or( [ newline
	
		, [ tab, dummy(d), q10( [ tab, dummy(d) ] ), tab, dummy(d), newline ]
		
	] )

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_line_rule( line_continuation_line, [ read_ahead(dummy(s)), check(dummy(start) > -300), append(line_descr(s1), ` `,``), newline ]).
%=======================================================================

