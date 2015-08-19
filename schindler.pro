%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - SCHINDLER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( schindler, `19 March 2015` ).

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
	    , suppliers_code_for_buyer( `10019539` )                      %PROD
	]) ]


%	, suppliers_code_for_buyer( `10019539` )   %PROD
%	, suppliers_code_for_buyer( `11205959` )   %TEST

	, customer_comments( `` )
	, shipping_instructions( `` )

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_email ]

	,[q0n(line), due_date_line ]

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

	 , q(0, 2, line)

	 , q10(delivery_dept_line)

	 , q10(delivery_address_line_line)

	 , delivery_street_line

	 , delivery_city_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	q0n(anything)

	, read_ahead( [`Anlieferanschrift`, `:`])

	, anlieferanschrift(w)

	, trace([ `delivery header found` ])

	
]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	nearest( anlieferanschrift(start), 10, 10 )

	, delivery_party(s1)

	, trace([ `delivery party`, delivery_party ])

	, newline
	
]).

%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	nearest( anlieferanschrift(start), 10, 10 )

	, delivery_dept(s1)

	, trace([ `delivery dept`, delivery_dept ])

	, newline
	
]).

%=======================================================================
i_line_rule( delivery_address_line_line, [ 
%=======================================================================

	nearest( anlieferanschrift(start), 10, 10 )

	, delivery_address_line(s1)

	, trace([ `delivery address line`, delivery_address_line ])

	, newline
	
]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	nearest( anlieferanschrift(start), 10, 10 )

	, delivery_street(s1)

	, trace([ `delivery street`, delivery_street ])

	, newline
	
]).

%=======================================================================
i_line_rule( delivery_city_line, [ 
%=======================================================================
	
	nearest( anlieferanschrift(start), 10, 10 )

	, delivery_postcode(d)

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

	`Best`, `-`, `Nr`, `.`, `/`, `Gruppe`, `:`, tab(100)

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

	, trace( [ `order number`, order_number ] ) 

	, tab, `Wien`,  newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`Kontaktperson`, `:`, tab

	, buyer_contact(s1)

	, trace([ `buyer contact`, buyer_contact ])

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	`Tel`, `/`, `Fax`, `:`, tab

	, buyer_ddi(w)

	, append(buyer_ddi(w), ``, ``)

	, trace([ `buyer ddi`, buyer_ddi ])

	, `/`

	, buyer_fax(w)

	, append(buyer_fax(w), ``, ``)

	, trace([ `buyer fax`, buyer_fax ])

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	`E`, `-`, `mail`, `:`, tab

	, buyer_email(s1)

	, trace([ `buyer email`, buyer_email ])

] ).


%=======================================================================
i_line_rule( due_date_line, [ 
%=======================================================================

	q0n(anything)

	, `lieferdatum`, `:`, q01(tab)

	, due_date(date)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	`Gesamtnettowert`, `ohne`, `MWST`, `EUR`, tab

	, read_ahead(total_invoice(d))

	, total_net(d)

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section_end( get_invoice_lines, line_end_line ).
%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
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
i_line_rule_cut( line_header_line, [ `Lieferdatum`, tab, `Bestellmenge`, `Einheit`, tab, `Preis`] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or([ [`Gesamtnettowert`, `ohne`, `MWST`, `EUR`] 

	, [`Seite`, num(d), `/`, num(d),  newline] ])

] ).

%=======================================================================
i_line_rule_cut( skip_lines_line, [
%=======================================================================

	`_`, `_`, `_`, `_`, `_`, `_`, `_`, `_`, `_`

] ).

%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	line_descr_line

	, q01(skip_lines_line)

	, line_values_line

	, q01(skip_lines_line)

	, or([ [q(0, 2, line), line_item_code_line], line_item(`Missing`) ])

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, trace( [ `original order date set to`, line_original_order_date ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	line_order_line_number(d), tab

	, trace([ `line order line number`, line_order_line_number ])

	, q10([line_item_for_buyer(s1), tab])

	, line_descr(s1)

	, trace([ `line description`, line_descr ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	q10( [ some(date), tab ] )
	
	, line_quantity(d), q10( tab )

	, trace([ `line quantity`, line_quantity ])

	, line_quantity_uom_code(w), tab

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, unitamount(s1), tab

	, trace([ `unit amount` ])

	, line_net_amount(d)

	, trace([ `line net amount`, line_net_amount ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( line_item_code_line, [
%=======================================================================

	 qn1( 
		or( [ `Ihre`
			, `Materialnummer`
			, `art`
			, `.`
			, `nr`
			, `:`
			, `Artikelnummer`
		] ) 
	)

	, line_item(s)

	, trace([ `line item`, line_item ])

	, newline

] ).