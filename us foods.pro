%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US FOODS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_foods, `28 April 2015` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%i_pdf_parameter( space, 2 ).
% i_pdf_parameter( tab, 10 ).
% i_pdf_parameter( new_line, 6 ).
% i_pdf_parameter( font_size, 30 ).  
%i_pdf_parameter( max_pages, 1 ).

i_op_param( us_invoice, _, _, _, true ).

% default is to use the line
% i_calculate_vat_totals_from_table.

i_date_format(  'm/d/y' ).

json_custom_field( `ACCOUNT_NUMBER`, suppliers_code_for_buyer ).

json_custom_line_field( `Note`, `01MSK-97020-00000-00206` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 get_buyer_and_supplier_codes

	, [ q0n(line), invoice_or_credit_note_line ]

	, invoice_number_and_date_rule
	
	, get_credit_note_date

	, get_buyer_email

	, currency(`USD`)
	, suppliers_code_for_buyer( `50313667` )

	, get_invoice_lines
	
	, get_credit_lines

	, get_invoice_totals

] ).


%=======================================================================
i_rule( get_buyer_and_supplier_codes, [
%=======================================================================

	supplier_registration_number( FROM )

	, buyer_registration_number( TO )
] )

:-

	i_mail( from, FROM )

	, i_mail( to, TO )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE OR CREDIT NOTE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule_cut( invoice_or_credit_note_line, [
%=======================================================================

	   q0n(word)

	, or( [
		[ `invoice`, newline,  trace( [ `this is an invoice` ] ) ]

		, [ `credit`, `Note`, newline,  set(credit_note), trace( [ `this is a credit note` ] ) ]
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( invoice_number_and_date_rule, [ 
%=======================================================================

	  q(0,3,line), invoice_number_header_line
	  
	, invoice_number_and_date_line

] ).

%=======================================================================
i_line_rule( invoice_number_header_line, [
%=======================================================================

	`ACCOUNT`, `NUMBER`, tab
 
	, or( [ `INVOICE`
 
		, [ `CREDIT`, `MEMO`, set( credit_note ) ] 
	
	] ), `NUMBER` 
 
] ).

%=======================================================================
i_line_rule( invoice_number_and_date_line, [ 
%=======================================================================

	  word, tab
	  
	, generic_item( [ invoice_number, s1, tab ] )
	
	, generic_item( [ Var, Par ] )

] )
:-
	( grammar_set( credit_note )
		->	Var = original_invoice_number,
			Par = s1
	
		;	Var = invoice_date,
			Par = date
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREDIT DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_credit_note_date, [ 
%=======================================================================

	 q(0,5,line), generic_vertical_details( [ [ `Credit`, `Memo`, `Date` ], invoice_date_x, date ] )
	 
	, check( invoice_date_x = Date_X )
	, check( sys_string_split( Date_X, `/`, [ Y, M, D ] ) )
	, check( sys_stringlist_concat( [ M, D, Y ], `/`, Date ) )
	, invoice_date( Date )
	, trace( [ `Final date`, Date ] )

] ):- grammar_set( credit_note ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	q(0,30,line)
	
	, generic_horizontal_details( [ [ at_start, `ATTN`, q10( `:` ) ], buyer_contact, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ at_start, `Product`, `Total` ], 500, total_net, d ] )

	, q10( sales_tax_line )
	
	, q(0,4,line), total_due_line

] ).


%=======================================================================
i_line_rule( sales_tax_line, [
%=======================================================================
	
	q0n(anything)

	, `Sales`, `Tax`, tab
	
	, `Rate`, `:`, dummy_num(d), tab, `$`

	, read_ahead(rate_1_vat(d)), vat_code_1(`SALES`), vat_rate_1(`0`), rate_1_net(`0`), rate_1_gross(`0`)

	, total_vat(d)

	, newline

	, trace( [ `total tax`, total_vat] )
	
] ).

%=======================================================================
i_line_rule( total_due_line, [
%=======================================================================
	
	  q0n(anything)
	
	, or( [ [ `PLEASE`, `REMIT`, `THIS`, `AMOUNT`, `BY`, q10( tab )
	
			, dummy_date(date)
		
		]
		
		, [ test( credit_note ), `AMOUNT` ]
		
	] ), tab, `$`

	, total_invoice(d), q10( `CR` ), newline

	, trace( [ `total invoice`, total_invoice ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line
	
	, peek_fails( [ 
		q(1,3,up)
		, generic_line( [ [ read_ahead( generic_item( [ dummy, s1 ] ) ), q0n(word), `Summary` ] ] )
		
	] )

	, qn0( [ peek_fails(line_end_line)

		, or([ get_line_invoice

			, line_continuation_line

			, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ peek_fails( test( credit_note ) ), `ORD`, q10( tab ), `SHP` ] ).
%=======================================================================
i_line_rule( line_continuation_line, [ peek_fails( [ dummy(w), check( dummy(start) < -300 ) ] ), append(line_descr(s1), ` `,``), newline  ]).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ [ `INVOICE`, `SUMMARY` ]
	
		, [ `Page` ]
		
		, [ `Product`, `Class`, `Recap` ]
		
		, [ `Quantity`, tab, `Sales` ]
		
	] ) 
	
] ).

%=======================================================================
i_rule_cut( retab_item( [ Var, Par ] ), [ or( [ generic_item( [ Var, Par, tab ] ), tab ] ) ] ).
%=======================================================================
i_line_rule_cut( get_line_invoice, [
%=======================================================================

	retab( Retab )
	
	, or( [ retab_item( [ ordered, d ] )
	
		, [ `*`, `SUB`, `*`, tab ]
		
	] )

	, retab_item( [ line_quantity_x, d ] )
	
	, retab_item( [ adjustment, d ] )
	
	, retab_item( [ sales_unit, s1 ] )
	
	, retab_item( [ line_item, s1 ] )
	
	, retab_item( [ line_descr, s1 ] )
	
	, retab_item( [ label, s1 ] )
	
	, retab_item( [ pack_size, s1 ] )
	
	, retab_item( [ code, s1 ] )
	
	, or( [ generic_item( [ weight, d, [ set( got_weight ), tab ] ] ), tab ] )
	
	, retab_item( [ pricing_unit, s1 ] )
	
	, retab_item( [ line_unit_amount, d ] )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
	, or( [ [ test( got_weight ), check( weight = Qty ) ]
	
		, [ peek_fails( test( got_weight ) ), check( line_quantity_x = Qty ) ]
		
	] )
	
	, line_quantity( Qty )
	, trace( [ `Line Quantity`, line_quantity ] )
	
	, clear( got_weight )
	
	, q10( [ check( line_quantity_x = Qty_x )
		, check( q_sys_comp_str_eq( Qty_x, `0` ) )
		, line_type( `ignore` )
	] )

] )
:-
	i_mail( attachment, Attach ),
	string_to_lower( Attach, AttachL ),
	( q_sys_sub_string( AttachL, _, _, `docx` )
		-> 	Retab = [ -435, -405, -370, -327, -271, -11, 87, 143, 180, 225, 290, 360 ]
		
		;	Retab = [ -440, -403, -368, -320, -260, 12, 111, 182, 226, 280, 335, 405 ]
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_credit_lines, [
%=======================================================================

	line_credit_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ get_line_credit

			, line_continuation_line

			, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_credit_header_line, [ test( credit_note ), `UNIT`, q10( tab ), `NUMBER` ] ).
%=======================================================================
i_line_rule_cut( get_line_credit, [
%=======================================================================

	retab( [ -410, -360, -300, 12, 111, 182, 226, 280, 335, 405 ] )
	
	, retab_item( [ line_quantity_x, n ] )

	, retab_item( [ sales_unit, s1 ] )
	
	, retab_item( [ line_item, s1 ] )
	
	, retab_item( [ line_descr, s1 ] )
	
	, retab_item( [ label, s1 ] )
	
	, retab_item( [ pack_size, s1 ] )
	
	, retab_item( [ code, s1 ] )
	
	, or( [ generic_item( [ weight, d, [ set( got_weight ), tab ] ] ), tab ] )
	
	, retab_item( [ pricing_unit, s1 ] )
	
	, retab_item( [ line_unit_amount, d ] )
	
	, `(`, generic_item( [ line_net_amount, d, [ `)`, newline ] ] )
	
	, or( [ [ test( got_weight ), check( weight = Qty ) ]
	
		, [ peek_fails( test( got_weight ) ), check( line_quantity_x = Qty ) ]
		
	] )
	
	, line_quantity( Qty )
	, trace( [ `Line Quantity`, line_quantity ] )
	
	, clear( got_weight )

	, q10( [ check( line_quantity_x = Qty_x )
		, check( q_sys_comp_str_eq( Qty_x = `0` ) )
		, line_type( `ignore` )
	] )
	
] ).
