%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - PMS Elektro
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( pms_elektro, `28 June 2013` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `AT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11205957` ) ]    %TEST
	    , suppliers_code_for_buyer( `12141765` )                      %PROD
	]) ]

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_email]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_number_two ]

	,[q0n(line), get_invoice_date ]

	,[q0n(line), get_due_date ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

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

	  delivery_header_line

	 , delivery_party_line

	 , q10(delivery_dept_line)

	 , q10(delivery_address_line)

	 , q10(customer_comments_line)

	 , q10(customer_comments_line_two)

	 , q10(customer_comments_line_three)

	 , delivery_street_line

	 , delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`lieferanschrift`, `:`, newline

	, trace([ `delivery header found` ])

]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	delivery_party(s1)

	, trace([ `delivery party`, delivery_party ])

	, newline
	
]).

%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	delivery_dept(s1)

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
i_line_rule( customer_comments_line, [ 
%=======================================================================

	customer_comments(s1)

	, trace([ `customer comments`, customer_comments])

	, newline
	
]).

%=======================================================================
i_line_rule( customer_comments_line_two, [ 
%=======================================================================

	append(customer_comments(s1), `~`, ``)

	, trace([ `customer comments`, customer_comments])

	, newline
	
]).

%=======================================================================
i_line_rule( customer_comments_line_three, [ 
%=======================================================================

	append(customer_comments(s1), `~`, ``)

	, trace([ `customer comments`, customer_comments])

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
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(anything)

	,`Bearbeiter`, `:`, tab

	, buyer_contact(s1)

	, newline

	, trace( [ `order date`, invoice_date ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	`Tel`, `.`, `DW`, `:`, tab, `+`, num(d)

	, `(`, buyer_ddi(d), `)`

	, append(buyer_ddi(w), ``, ``)

	, append(buyer_ddi(w), ``, ``), `-`

	, append(buyer_ddi(w), ``, ``)

	, newline

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	q0n(anything)

	,`Mail`, `:`, tab

	, buyer_email(s1)

	, newline

	, trace( [ `order date`, invoice_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	get_order_number_header

	, get_order_number_line

] ).

%=======================================================================
i_line_rule( get_order_number_header, [ 
%=======================================================================

	`Bestellung`, `(`, `ig`, `.`, `Lieferung`, `)`,  newline

	, trace( [ `order number header found` ] ) 

] ).

%=======================================================================
i_line_rule( get_order_number_line, [ 
%=======================================================================

	order_number(s1)

	, newline

	, trace( [ `order number`, order_number ] ) 

] ).

%=======================================================================
i_line_rule( get_order_number_two, [ 
%=======================================================================

	without(order_number)

	,`Bestellung`

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

	q0n(anything)

	,`Bestelldatum`, tab

	, invoice_date(date)

	, newline

	, trace( [ `order date`, invoice_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_due_date, [ 
%=======================================================================

	`Liefertermin`, `:`

	, due_date(date)

	, newline

	, trace( [ `due date`, due_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	`G`, `e`, `s`, `a`, `m`, `t`, `ohne`, `Umsatzsteuer`, `EUR`, tab

	, read_ahead(total_invoice(d))

	, total_net(d)

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

	, qn0( [ peek_fails(line_end_line)

		, or([ line_invoice_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Best`, `-`, `Pos`, `.`, tab, `Bezeichnung`, tab, `Menge` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`G`, `e`, `s`, `a`, `m`, `t`, `ohne`, `Umsatzsteuer`, `EUR`, tab

] ).

%=======================================================================
i_rule_cut( line_invoice_line, [
%=======================================================================

	line_values_line

	, line_descr_line
	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)


] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	line_order_line_number_x(d), tab

	, trace([ `line order line number`, line_order_line_number ])

	, line_item(s1), tab

	, trace([ `line item`, line_item ])

	, line_quantity(d)

	, trace([ `line quantity`, line_quantity ])

	, line_quantity_uom_code(w), tab

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, q0n(anything)

	, line_net_amount(d)

	, trace([ `line net amount`, line_net_amount ])

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, trace( [ `original order date set to`, line_original_order_date ] )

	, newline

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	line_descr(s1), newline

	, trace([ `line description`, line_descr ])

] ).