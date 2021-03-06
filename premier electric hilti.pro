%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - PREMIER ELECTRIC HILTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( premier_electric_hilti, `29 April 2014` ).

i_date_format( _ ).

i_user_field( invoice, street_two, `street two storage` ).

i_user_field( invoice, due_date_year, `due date year storage` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables

	, get_order_number

	, get_invoice_date
	
	, get_delivery_address

	, [ without(delivery_city), delivery_note_number(`12356984`) ]
	
	, get_email_address

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `GB-PREMELE` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `12356984` )

	, delivery_party( `PREMIER ELECTRIC LTD` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q( 0, 8, line )
	
	, order_number_line

] ).

%=======================================================================
i_line_rule_cut( order_number_line, [
%=======================================================================

	q0n(anything)
	
	, `Order`, `No`, `.`
	
	, tab
	
	, order_number(s1)
	
	, newline
	
	, trace( [ `Order Number`, order_number ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [
%=======================================================================

	q( 0, 10, line )
	
	, invoice_date_line

] ).

%=======================================================================
i_line_rule_cut( invoice_date_line, [
%=======================================================================

	q0n(anything)
	
	, `Order`, `Date`
	
	, tab
	
	, invoice_date(d), append( invoice_date(s1), ` `, `` )
	
	, newline
	
	, trace( [ `Invoice Date`, invoice_date ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	q( 0, 10, line )
	
	, delivery_location_line
	
	, q0n(line)
	
	, ship_to_address_line
	
	, line
	
	, delivery_street_line
	
	, or( [ [ delivery_city_line, delivery_postcode_line ]
	
		, delivery_city_and_postcode_line
		
	] )
	
	, customer_comments_line

] ).

%=======================================================================
i_line_rule_cut( delivery_location_line, [
%=======================================================================

	q0n(anything)
	
	, `Job`, `No`, `.`
	
	, tab
	
	, delivery_location(s1)
	
	, trace( [ `Delivery Location`, delivery_location ] )

] ).

%=======================================================================
i_line_rule_cut( ship_to_address_line, [
%=======================================================================

	`Ship`, `-`, `to`, `Address`

] ).

%=======================================================================
i_line_rule_cut( delivery_street_line, [
%=======================================================================

	or( [ [ read_ahead( [ dummy1(d), dummy2(d) ] ), delivery_street(d), append( delivery_street(s1), ` - `, `` ) ]
	
		, delivery_street(s1)
		
	] )
	
	, trace( [ `Delivery Street`, delivery_street ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_city_line, [
%=======================================================================

	delivery_city(s1)
	
	, trace( [ `Delivery City`, delivery_city ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_postcode_line, [
%=======================================================================

	delivery_postcode(pc)
	
	, trace( [ `Delivery Postcode`, delivery_postcode ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_city_and_postcode_line, [
%=======================================================================

	delivery_city(sf)
	
	, trace( [ `Delivery City`, delivery_city ] )
	
	, delivery_postcode(pc)
	
	, trace( [ `Delivery Postcode`, delivery_postcode ] )

] ).

%=======================================================================
i_line_rule_cut( customer_comments_line, [
%=======================================================================

	customer_comments(s1)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET EMAIL ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_email_address, [
%=======================================================================

	buyer_contact(Buyer_Contact)
	
	, buyer_email(From)

] )
:-

	i_mail( from, From )
	
	, sys_string_split( From, `@`, [ Name | _ ] )
	
	, string_string_replace( Name, `.`, ` `, Buyer_Contact )
	
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line

	, q0n( [ or( [ line_invoice_line
			
			, line

		] )

	] )

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Description`, tab, `Quantity` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Total`, `£`, q10( [ `Excl`, `.`, `VAT` ] ), tab ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	read_ahead( line_descr(s1) )
	
	, trace( [ `Description`, line_descr ] )
	
	, or([ [ q0n(word), line_item( f([ begin, q(dec,4,9), end ]) )  ]

		, [ `DX460`, line_item(`305171`) ]
	
		, line_item(`missing`)
		
	] )
	
	, q0n(word), tab
	
	, trace( [ `Item Code`, line_item ] )
	
	, line_quantity(d)
	
	, q10(tab)
	
	, trace( [ `Quantity`, line_quantity ] )
	
	, line_quantity_uom_code(w)
	
	, tab
	
	, trace( [ `Quantity UOM Code`, line_quantity_uom_code ] )
	
	, q0n(anything)
	
	, or( [ [ tab
	
			, read_ahead( line_net_amount(d) )
			
			, line_total_amount(d)
			
			, check( line_total_amount(start) > 370 )
			
		]
		
		, [ line_net_amount(`0`)
			
			, line_total_amount(`0`)
			
		]
		
	] )
	
	, newline
	
	, trace( [ `Line Net Amount`, line_net_amount ] )
	
	, trace( [ `Line Total (Gross) Amount`, line_total_amount ] )
	
	, count_rule

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	q0n(line)
	
	, total_net_line

] ).

%=======================================================================
i_line_rule( total_net_line, [
%=======================================================================

	`Total`, `£`, q10( [ `Excl`, `.`, `VAT` ] )
	
	, tab
	
	, read_ahead( total_net(d) )
	
	, total_invoice(d)
	
	, newline
	
	, trace( [ `Total Net Amount`, total_net ] )
	
	, trace( [ `Total (Gross) Amount`, total_invoice ] )

] ).











