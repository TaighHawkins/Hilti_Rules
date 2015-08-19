%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FOCCHI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( focchi, `16 September 2014` ).

i_date_format( _ ).

i_pdf_parameter( same_line, 6 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, set_live

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `IT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10658906` ), delivery_note_number( `10658906` )  ]    %TEST
	    , [ suppliers_code_for_buyer( `13063208` ), delivery_note_number( `13063208` ) ]                      %PROD
	]) ]

	, customer_comments( `` )
	, shipping_instructions( `` )

	, [ q0n(line), customer_comments_line ]

	, [ q0n(line), shipping_instructions_line ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_delivery_contact ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, total_net(`0`)

	, total_invoice(`0`)

	%,[ q0n(line), get_invoice_total_number]

	, delivery_contact(``)
	


] ).


%=======================================================================
i_rule( set_live, [ set( hilti_live ), trace([`Set LIVE flag`]) ]) :- i_mail(to,`hilti.orders@adaptris.net`).
%=======================================================================
i_rule( set_live, [ set( hilti_live ), trace([`Set LIVE flag`]) ]) :- i_mail(to,`hilti.orders@ecx.adaptris.com`).
%=======================================================================



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything)

	, `order`, `nr`, `.`

	, order_number(w), q10(tab)

	, trace( [ `order number`, order_number ] ) 

	, `del`, q01(tab)

	, invoice_date(date)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_contact, [ 
%=======================================================================

	buyer_dept(`ITFOCC-`)

	, delivery_from_contact(`ITFOCC-`)

	, q0n(anything)

	,`emesso`, `da`, `:`

	, read_ahead([ append(delivery_from_contact(s1), ``, ``) ])

	, append(buyer_dept(s1), ``, ``)

	, trace([ `delivery from contact`, delivery_from_contact ])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_total_number, [
%=======================================================================

	q0n(anything)

	,`importo`, `netto`, `:`, tab, total_net(d)

	,`Totale`, `:`, tab

	, total_invoice(d)

	, `eur`

	, newline

	, trace( [ `total invoice`, total_invoice ] )	

	, trace( [ `total net`, total_net ] )	

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

	 , q0n( line_paragraph )

	 , line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `co`, `,`, `ge`, `,`, tab, `code` ] ).
%=======================================================================


%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================
	
	or([ [ `*`, `*`, `*`, `rendere`, `copia`, `firmata` ], [ `consegna`, `presso`, `cantiere` ] ])


] ).


%=======================================================================
i_rule( line_paragraph, [
%=======================================================================

	invoice_line( [ item_line ] )

	, invoice_line( [ description_line ] )

	, q0n( invoice_line( [ extra_description_line ] ) )


] ).


%=======================================================================
i_line_rule_cut( invoice_line( [ MIDDLE_BIT ] ), [
%=======================================================================

	retab( [ -380, 52, 100, 180, 265, 360 ] )

	, q10( [ line_item_for_buyer_x(w), trace([ `line item for buyer_x`, line_item_for_buyer_x ]) ] )

	, tab

	, MIDDLE_BIT

	, tab

	, q10( [ line_quantity_uom_code(w), trace([ `line quom`, line_quantity_uom_code ]) ] )

	, tab
	
	, q10( [ line_quantity(d), trace([ `line quantity`, line_quantity ]) ] )

	, tab

	, q10( [ line_unit_amount_x(d), trace([ `line_unit_amount`, line_unit_amount ]) ] )

	, tab

	, q10( [ line_percent_discount_x(d), trace([ `line_percent_discount`, line_percent_discount ]) ] )

	, tab

	, q10( [ line_original_order_date(date), trace( [ `line_original_order_date`, line_original_order_date ] ) ] )
] ).

%=======================================================================
i_rule_cut( item_line, [
%=======================================================================

	line_item_for_buyer( w1 )

	, check( line_item_for_buyer(start) < -300 )

	, or( [ [ line_item( f( [ begin, q(dec,3, 15), end, q(other("/"),0,1), q(any,0,10) ]) ) 

			, check( line_item(start) > -100 )

			, trace( [ `line_item`, line_item, `extra code(unused)`, cod ] )
			
		]
		
		, [ `*`, `*`, `*`, line_item( `Missing` ) ]
		
	] )

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)


] ).

%=======================================================================
i_rule_cut( description_line, [ read_ahead( line_descr(s1) ), descr(s1), trace( [ `descr`, descr ] ) ] ).
%=======================================================================
i_rule_cut( extra_description_line, [ read_ahead( append( line_descr(s1), ` `, `` ) ), descr(s1), trace( [ `extra descr`, descr ] ) ] ).
%=======================================================================


