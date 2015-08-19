%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - MODUBLOK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( modublok, `20 March 2015` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `IT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10658906` ) ]    %TEST
	    , suppliers_code_for_buyer( `13019237` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), delivery_note_number( `10658906` ) ]    %TEST
	    , delivery_note_number( `12904548` )                      %PROD
	]) ]


	, buyer_contact(`DONATO ROK`)

	, buyer_email(`ufficioacquisti@modulblok.it`)

	, delivery_contact(`DONATO ROK`)

	, delivery_email(`ufficioacquisti@modulblok.it`)

	, shipping_comments( `` )
	, shipping_instructions( `` )

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	,[ qn0(line), invoice_total_line]
	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	`ORDINE`, `A`, `FORNITORE`, tab

	, order_number(s1)

	, tab, any(date)

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

	`ORDINE`, `A`, `FORNITORE`, tab

	, q0n(anything)

	, invoice_date(date)

	, trace( [ `order date`, invoice_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	q0n(anything)

	, `eur`, tab
	
	, set(regexp_cross_word_boundaries)

	, read_ahead(total_invoice(d))

	, total_net(d)
	
	, clear(regexp_cross_word_boundaries)

	, newline

	, trace([ `total invoice`, total_invoice ])

	, trace([ `total net`, total_net ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ get_invoice_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ q01( [ dummy(s1), tab ] ), `ricevim`, `.`, tab, `1`, tab, `2`, tab, `3`, tab, `4` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `LEGENDA`, `PER`, `STANDARD`, `QUALITA` ]
	
		, [ `MODULBLOK`, `SPA` ]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( get_invoice_line, [
%=======================================================================

	generic_item( [ line_item_for_buyer, w ] ) 

	, generic_item_cut( [ line_descr,s1, tab ] )

	, q10([dummy(s1), tab])

	, q10( [ ordine(s), q10( tab ) ] )

	, generic_item_cut( [ line_original_order_date, date ] )

	, q0n(anything), tab

	, generic_item_cut( [ line_quantity, d, q10(tab) ] )

	, generic_item_cut( [ line_quantity_uom_code, s1, tab ] )

	, qty(d), q10(tab)

	, uom_code(s1), tab

	, generic_item_cut( [ line_unit_amount_x,d, tab ] )

	, set(regexp_cross_word_boundaries)

	, generic_item_cut( [ line_net_amount, d, newline ] )
	
	, clear(regexp_cross_word_boundaries)

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)


] ).