%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - KOEB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( koeb, `22 May 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `AT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, type_of_supply(`S0`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11205959` ) ]    %TEST
	    , suppliers_code_for_buyer( `10024830` )                      %PROD
	]) ]

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_email ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

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

	 , delivery_dept_line

	 , delivery_street_line

	 , delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`bitte`, `liefern`, `sie`, `an`, `:`

	, trace([ `delivery header found` ])

]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	delivery_party(s1)

	, check(delivery_party(end) < -40 )

	, trace([ `delivery party`, delivery_party ])
	
]).

%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	delivery_dept(s1)

	, check(delivery_dept(end) < -40 )

	, trace([ `delivery dept`, delivery_dept ])
	
]).

%=======================================================================
i_line_rule( delivery_address_line, [ 
%=======================================================================

	delivery_address_line(s1)

	, check(delivery_address_line(end) < -40 )

	, trace([ `delivery address line`, delivery_address_line ])

]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	delivery_street(s1)

	, check(delivery_street(end) < -40 )

	, trace([ `delivery street`, delivery_street ])

]).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================
	
	delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s1)

	, trace([ `delivery city`, delivery_city ])

	, check(delivery_city(end) < -40 )

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

	,`Ansprechpartner`, tab

	, buyer_contact(s1)

	, newline

	, trace( [ `buyer contact`, buyer_contact ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(anything)

	,`Telefon`, `/`, `Fax`, tab

	, buyer_ddi(sf), `/`

	, append(buyer_ddi(sf), ``, ``), `-`

	, append(buyer_ddi(sf), ``, ``), `/`

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	q0n(anything)

	,`e`, `-`, `mail`, `Adresse`, tab

	, buyer_email(s1)

	, newline

	, trace( [ `buyer email`, buyer_email ] ) 

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

	, line

	, get_order_number_line

] ).

%=======================================================================
i_line_rule( get_order_number_header, [ 
%=======================================================================

	`Bestellnummer`, `/`, `Org`, `.`, `/`, `Einkgrp`, `.`,  newline

	, trace( [ `order number header found` ] ) 

] ).

%=======================================================================
i_line_rule( get_order_number_line, [ 
%=======================================================================

	q0n(anything)

	, order_number(s1)

	, check(order_number(start) > 100 )

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

	,`Belegdatum`, tab

	, invoice_date(date)

	, newline

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

	`Gesamtsumme`, `ohne`, `MwSt`, `.`, `:`, tab

	, read_ahead(total_invoice(d))

	, total_net(d)

	, `eur`

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

		, or([ line_invoice_rule, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `einheit`, newline ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Gesamtsumme`, `ohne`, `MwSt`, `.`, `:`, tab

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_descr_line

	, or([

		[ line_values_line, q(0, 5, line), line_item_line ]

		, [ line_quantity_line, q(0, 5, line), line_item_line, q(0,5,line), netto_line ]

	])

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	line_order_line_number(d)

	, trace([ `line order line number`, line_order_line_number ])

	, line_item_for_buyer(s1), tab

	, trace([ `line item for buyer`, line_item_for_buyer ])

	, line_descr(s1), tab

	, trace([ `line description`, line_descr ])

	, line_original_order_date(date)

	, trace([ `line original order date`, line_original_order_date ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	line_quantity(d), tab

	, trace([ `line quantity`, line_quantity ])

	, line_quantity_uom_code(w)

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, q0n(anything)

	, tab, line_net_amount(d)

	, trace( [ `line net amount`, line_net_amount ] )

	, newline

] ).

%=======================================================================
i_line_rule_cut( line_quantity_line, [
%=======================================================================

	line_quantity(d), tab

	, trace([ `line quantity`, line_quantity ])

	, read_ahead( `Stück`), line_quantity_uom_code(w)

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

] ).


%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	`Ihre`, `Materialnummer`, tab

	, line_item(s1)

	, trace( [ `line item`, line_item ] )

	, newline

] ).



%=======================================================================
i_line_rule_cut( netto_line, [
%=======================================================================

	`Nettowert`

	, q0n(anything)

	, tab, line_net_amount(d)

	, trace( [ `line net amount`, line_net_amount ] )

	, newline

] ).
