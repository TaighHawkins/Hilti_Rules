%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - KNUF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( knuff, `19 August 2013` ).

i_date_format( _ ).

i_format_postcode( X, X ).


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

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10152760` ) ]    %TEST
	    , suppliers_code_for_buyer( `10152760` )                      %PROD
	]) ]

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_delivery_contact ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

	,[q0n(line), get_due_date ]

	,[q0n(line), get_customer_comments ]

	,[q0n(line), get_customer_comments_two ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

%	,[ qn0(line), invoice_total_line]
	, total_net(`0`), total_invoice(`0`)
	

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

	 , delivery_note_number_line

	 , delivery_party_line

	 , q10(delivery_dept_line)

	 , q10([ q(0, 2, delivery_address_line) ])

	 , delivery_street_line

	 , delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`Lieferanschrift`,  newline

	, trace([ `delivery header found` ])

]).

%=======================================================================
i_line_rule( delivery_note_number_line, [ 
%=======================================================================

	delivery_note_number(s1)

	, trace([ `delivery note number`, delivery_note_number ])

	, newline
	
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

	, dummy(w)

	, bc(`DEKNUF`)

	, append(bc(s1), ``, ``)

	, check( i_user_check( gen_string_to_upper, bc, BC  ) )

	, buyer_dept(BC)

	, newline

	, trace( [ `buyer dept`, buyer_dept ] ) 

] ).

%=======================================================================
i_line_rule( get_delivery_contact, [ 
%=======================================================================

	q0n(anything)

	,`Bearbeiter`, `:`, tab

	, dummy(w)

	, dc(`DEKNUF`)

	, append(dc(s1), ``, ``)

	, check( i_user_check( gen_string_to_upper, dc, DC  ) )

	, delivery_from_contact(DC)

	, newline

	, trace( [ `deliver from contact`, delivery_from_contact ] ) 

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

	,`nummer`, `:`, tab

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

	,`datum`, `:`, tab

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

	`Lieferdatum`, `:`, tab

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
i_line_rule( get_customer_comments, [ 
%=======================================================================

	q0n(anything)

	,`Projektnummer`, `:`, tab

	, customer_comments(`Projektnummber:`)

	, append(customer_comments(s1), ` `, ``)

	, newline

	, trace( [ `customer comments`, customer_comments] ) 

] ).

%=======================================================================
i_rule( get_customer_comments_two, [ 
%=======================================================================

	get_customer_comments_line_two

	, get_customer_comments_footer_two

] ).

%=======================================================================
i_line_rule( get_customer_comments_line_two, [ 
%=======================================================================

	append(customer_comments(s1), `~`, ``)

	, newline

	, trace( [ `customer comments`, customer_comments] ) 

] ).

%=======================================================================
i_line_rule( get_customer_comments_footer_two, [ 
%=======================================================================

	`Pos`, `.`, tab, `Menge`, tab, `Bezeichnung`

	, trace( [ `customer comments footer found` ]) 

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
i_line_rule_cut( line_header_line, [ `Pos`, `.`, tab, `Menge`, tab, `Bezeichnung` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	 `E`, `-`, `Mail`, `-`, `Gebr`, `.`, `Knuf`, `@`, `t`

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	line_order_line_number(d), tab

	, trace([ `line order line number`, line_order_line_number ])

	, line_quantity(d)

	, trace([ `line quantity`, line_quantity ])

	, line_quantity_uom_code(w), q10(tab)

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, line_descr(s1), tab

	, trace([ `line description`, line_descr ])

	, line_item(s1)

	, trace([ `line item`, line_item ])

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, trace( [ `original order date set to`, line_original_order_date ] )

	, newline

] ).