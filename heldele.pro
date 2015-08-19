%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HELDELE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( heldele, `11 August 2014` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `DE-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, buyer_dept( `DEHELD` )

	, or([  [test(test_flag), q0n(line), scfb_line_test] , [q0n(line), scfb_line_prod]  ])

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

	,[q0n(line), customer_comments_line_one ]

	,[q0n(line), customer_comments_line_two ]

	,[q0n(line), customer_comments_line_three ]

	, get_invoice_lines

	,[ qn0(line), invoice_total_line]
	

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

	 , q10(delivery_dept_line)

	 , q10(delivery_address_line)

	 , q10(delivery_address_line_two)

	 , delivery_street_line

	 , delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`Kom`, `.`, `-`, `Nr`, `.`, `/`, `Fa`, `.`

	, trace([ `delivery header found` ])

]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	`Lieferanschrift`, tab, `:`

	, delivery_party(s1)
	
	, q0n( [ tab, append( delivery_party(s1), ` `, `` ) ] ), newline

	, trace([ `delivery party`, delivery_party ])
	
]).

%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	delivery_dept(s1), q10( [ tab, append( delivery_dept(s1), ` `, ``) ] )

	, trace([ `delivery dept`, delivery_dept ])

	, newline
	
]).

%=======================================================================
i_line_rule( delivery_address_line, [ 
%=======================================================================

	delivery_address_line(s1)

	, trace([ `delivery address line`, delivery_address_line ])

	, newline
	
]).

%=======================================================================
i_line_rule( delivery_address_line_two, [ 
%=======================================================================

	delivery_address_line(s1)

	, trace([ `delivery address line`, delivery_address_line ])

	, newline
	
]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	delivery_street(s1)

	, trace([ `delivery street`, delivery_street ])

	, newline
	
]).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================
	
	delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s)

	, trace([ `delivery city`, delivery_city ])

	, newline
	
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything)

	, `Nr`, `.`, `:`, tab

	, order_number(s1)

	, newline

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

	`DATUM`, tab, `:`, tab

	, invoice_date(date)

	, newline

	, trace( [ `order date`, invoice_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( customer_comments_line_one, [ 
%=======================================================================

	read_ahead(`kommission`)

	, customer_comments(s1), tab

	, append(customer_comments(s), ``, ``), tab

	, append(customer_comments(s), ``, ``)

	, trace( [ `customer comments`, customer_comments ] ) 

	, newline

] ).

%=======================================================================
i_line_rule( customer_comments_line_two, [ 
%=======================================================================

	`UNSER`, `ZEICHEN`, q10( tab ), `:`, tab

	, append(customer_comments(`IHR ZEICHEN:`), `~`, ``)
	
	, read_ahead( append( buyer_dept(s1), ``, `` ) )

	, append(customer_comments(s1), ``, ``)

	, trace( [ `customer comments`, customer_comments ] ) 

	, newline

] ).

%=======================================================================
i_line_rule( customer_comments_line_three, [ 
%=======================================================================

	`Sachbearbeiter`, tab, `:`

	, append(customer_comments(`Sachbearbeiter:`), `~`, ``)

	, append(customer_comments(s1), ``, ``)

	, trace( [ `customer comments`, customer_comments ] )

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUUPPLIERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( scfb_line_test, [
%=======================================================================

	q0n(anything)

	, `Nr`, `.`, `:`, tab

	, or([ [number( f( [ begin,  q(dec("1234567"),1,1), q(any,5, 99), end ]) ), suppliers_code_for_buyer(`10267671`) ] %TEST

	, [number( f( [ begin,  q(dec("89"),1,1), q(any,5, 99), end ]) ), suppliers_code_for_buyer(`10321767`) ] ]) %TEST

	, trace( [ `suppliers code for buyer`, suppliers_code_for_buyer ] )	

] ).

%=======================================================================
i_line_rule( scfb_line_prod, [
%=======================================================================

	q0n(anything)

	, `Nr`, `.`, `:`, tab

	, or([ [number( f( [ begin,  q(dec("1234567"),1,1), q(any,5, 99), end ]) ), suppliers_code_for_buyer(`10128363`) ] %PROD

	, [number( f( [ begin,  q(dec("89"),1,1), q(any,5, 99), end ]) ), suppliers_code_for_buyer(`10128364`) ] ]) %PROD

	, trace( [ `suppliers code for buyer`, suppliers_code_for_buyer ] )	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	`Netto`, `-`, `Summe`, tab, `EUR`, tab

	, read_ahead(total_invoice(d))

	, total_net(d)

	, newline

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
i_line_rule_cut( line_end_section_line, [ or( [ [ q0n(anything),`seite`, tab, num(d), newline ], [ `Übertrag` ] ] ) ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line
	 
	, trace( [ `found header` ] )

	, qn0( [ peek_fails(line_end_line)

		, or([ line_invoice_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Nr`, tab, `Menge`, q10( tab ), `Beschreibung`, tab, `EUR` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Netto`, `-`, `Summe`, tab, `EUR`

] ).

%=======================================================================
i_rule_cut( line_invoice_line, [
%=======================================================================

	line_values_line

	, line_descr_line

	, q(0, 6, line), peek_fails( line_values_line ), line_item_line 

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	line_order_line_number(d), tab

	, trace([ `line order line number`, line_order_line_number ])

	, line_quantity(d), q10( tab )

	, trace([ `line quantity`, line_quantity ])

	, line_quantity_uom_code(w)

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, q0n(anything)

	, line_net_amount(d)

	, trace([ `line net amount`, line_net_amount ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	line_descr(s1), newline

	, trace([ `line description`, line_descr ])

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	line_item(d), newline

	, trace([ `line item`, line_item ])

] ).

i_op_param( buyer_dept, _, _, _, `upper` ).