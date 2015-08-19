%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BERLINER WASSERBETRIEBE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( berliner_wasserbetriebe, `7 May 2013` ).

i_date_format( _ ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `DE-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

%	, suppliers_code_for_buyer( `10324274` )    %TEST
	, suppliers_code_for_buyer( `10299731` )    %PROD

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

%	,[q0n(line), get_buyer_ddi ]

%	,[q0n(line), get_buyer_fax ]

%	,[q0n(line), get_buyer_email ]

	,[q0n(line), get_delivery_contact ]

%	,[q0n(line), get_delivery_ddi ]

%	,[q0n(line), get_delivery_fax ]

%	,[q0n(line), get_delivery_email ]

	,[q0n(line), get_order_number ]

%	,[q0n(line), get_order_date ]

%	, customer_comments( `Customer Comments` )
%	,[q0n(line), customer_comments_line ] 

%	, shipping_instructions( `Shipping Instructions` )
%	,[q0n(line), shipping_instructions_line ]

	,[ q0n(line), get_general_original_order_date]

	, get_invoice_lines

	,[q0n(line), get_invoice_totals ]

%	, default_vat_rate(`19`)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	 or([ get_delivery_with_party_address , get_delivery_without_party_address ])

	 
] ).

%=======================================================================
i_rule( get_delivery_with_party_address, [
%=======================================================================
 
	  get_delivery_header_line

	, get_delivery_party_line

	, get_delivery_dept_line

	, q10(get_delivery_address_line)

	, get_delivery_street_line

	, get_delivery_postcode_city_line
	 
] ).

%=======================================================================
i_line_rule( get_delivery_header_line, [
%=======================================================================
 
	 `Bitte`, `liefern`, `Sie`, `an`, `:`

	, trace([ `delivery header found ` ])

] ).

%=======================================================================
i_line_rule( get_delivery_party_line, [
%=======================================================================
 
	delivery_party(s1)

	, trace([ `delivery party`, delivery_party ])

] ).

%=======================================================================
i_line_rule( get_delivery_dept_line, [
%=======================================================================
 
	delivery_dept(s1)

	, trace([ `delivery dept`, delivery_dept ])

] ).

%=======================================================================
i_line_rule( get_delivery_address_line, [
%=======================================================================
 
	delivery_address_line(s1)

	, trace([ `delivery address line`, delivery_address_line ])

] ).

%=======================================================================
i_line_rule( get_delivery_street_line, [
%=======================================================================
 
	delivery_street(s1)

	, trace([ `delivery street`, delivery_street ])

] ).

%=======================================================================
i_line_rule( get_delivery_postcode_city_line, [
%=======================================================================
 
	delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s)

	, trace([ `delivery city`, delivery_city ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	                       WITHOUT PARTY                              %

%=======================================================================
i_rule( get_delivery_without_party_address, [
%=======================================================================
 
	  get_delivery_header_line

	, get_delivery_party_line

%	, get_delivery_dept_line

	, get_delivery_street_line

	, get_delivery_postcode_city_line
	 
] ).

%=======================================================================
i_line_rule( get_delivery_header_line, [
%=======================================================================
 
	 `Bitte`, `liefern`, `Sie`, `an`, `:`

	, trace([ `delivery header found ` ])

] ).

%=======================================================================
i_line_rule( get_delivery_dept_line, [
%=======================================================================
 
	delivery_dept(s1)

	, trace([ `delivery dept`, delivery_dept ])

] ).

%=======================================================================
i_line_rule( get_delivery_street_line, [
%=======================================================================
 
	delivery_street(s1)

	, trace([ `delivery street`, delivery_street ])

] ).

%=======================================================================
i_line_rule( get_delivery_postcode_city_line, [
%=======================================================================
 
	delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s)

	, trace([ `delivery city`, delivery_city ])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`anforderer`, `:` 

	, buyer_contact(s)

	, trace([ `buyer contact`, buyer_contact ])

	, `,`, `tel`, `.`, `:`

	, buyer_ddi(s)

	, trace([ `buyer ddi`, buyer_ddi ])

	, `,`, `e`, `-`, `mail`, `:`

	, buyer_email(s1)

	, trace([ `buyer email`, buyer_email ])

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_contact, [ 
%=======================================================================

	`anforderer`, `:` 

	, delivery_contact(s)

	, trace([ `delivery contact`, delivery_contact ])

	, `,`, `tel`, `.`, `:`

	, delivery_ddi(s)

	, trace([ `delivery ddi`, delivery_ddi ])

	, `,`, `e`, `-`, `mail`, `:`

	, delivery_email(s1)

	, trace([ `delivery email`, delivery_email ])

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	order_number_header_line

	, line

	, get_order_number_line

] ).

%=======================================================================
i_line_rule( order_number_header_line, [ 
%=======================================================================

	`Bestellnummer`, `/`, `Datum`

	, trace( [ `order number header found` ] ) 

	, newline

] ).

%=======================================================================
i_line_rule( get_order_number_line, [ 
%=======================================================================

	order_number(s),`/`

	, trace( [ `order number`, order_number ] )  

	, invoice_date(date)

	, trace( [ `invoice date`, invoice_date] ) 

	, newline 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================

	`Belegdatum`, tab
	
	, invoice_date(w), `.`

	, or([ [ `märz`, append(invoice_date(`03`), ` `, ``) ]

	,[ `april`, append(invoice_date(`04`), ` `, ``) ]

	,[ `mai`, append(invoice_date(`05`), ` `, ``) ]

	,[ `juni`, append(invoice_date(`06`), ` `, ``) ]

	,[ `juli`, append(invoice_date(`07`), ` `, ``) ]

	,[ `august`, append(invoice_date(`08`), ` `, ``) ]

	,[ `september`, append(invoice_date(`09`), ` `, ``) ]

	,[ `oktober`, append(invoice_date(`10`), ` `, ``) ]

	,[ `november`, append(invoice_date(`11`), ` `, ``) ]

	,[ `dezember`, append(invoice_date(`12`), ` `, ``) ] ])

	, append(invoice_date(d), ` `, ``)

	, trace( [ `invoice date`, invoice_date] )

	, newline

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	`progetto`, tab
	
	, customer_comments(s), tab

	, append(customer_comments(s), ` `, ``)

	, newline

	, trace( [ `customer comments`, customer_comments ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( shipping_instructions_line, [ 
%=======================================================================

	`progetto`, tab
	
	, shipping_instructions(s), tab

	, append(shipping_instructions(s), ` `, ``)

	, newline

	, trace( [ `shipping instructions`, shipping_instructions ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_totals, [
%=======================================================================

	`Gesamt`, `ohne`, `USt`, `.`, q10( tab ), `EUR`, tab

	, read_ahead(total_net(d))

	, trace( [ `total vat`, total_vat ] )

	, total_invoice(d), newline

	, trace( [ `total invoice`, total_invoice ] )

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

		, or([ get_invoice_line, get_invoice_item_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, tab, `Material`, tab, `Bestellmenge` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or([ [`Gesamt`, `ohne`, `USt`, `.`, `EUR`, tab]

	, [`Bankverbindung`, `:`, `Berliner`, `Sparkasse`] ])

] ).

%=======================================================================
i_rule( get_invoice_line, [
%=======================================================================

	get_invoice_values_line

	, get_invoice_descr_line	

] ).

%=======================================================================
i_line_rule( get_invoice_values_line, [
%=======================================================================

	line_order_line_number(w), tab

	, line_quantity(d)

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(s1), tab

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, unitamount(s), tab

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount ])

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, trace( [ `original order date set to`, line_original_order_date ] )

	, newline

] ).

%=======================================================================
i_line_rule( get_invoice_descr_line, [
%=======================================================================

	line_descr(s1)

	, trace([`line descr`, line_descr ])

	, newline

] ).

%=======================================================================
i_line_rule( get_invoice_item_line, [
%=======================================================================

	  or( [ [ `Ihre`, `Artikelnummer` ]
	  
			, [ or( [ [ `Art`, `.` ], [ `Artikel` ] ] )
			
				, `-`, `Nr`, `.`, `:`
				
			]
				
		] )

	, line_item(s1)

	, trace([`line item`, line_item])

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERAL ORIGINAL ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_general_original_order_date, [ 
%=======================================================================

	q0n(anything)

	,`liefertermin`, tab

	, due_date(date)

	, newline

]).
