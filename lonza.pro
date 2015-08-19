%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - LONZA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( lonza, `04 February 2014` ).

i_date_format( _ ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `CH-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2100`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11202554` ) ]    %TEST
	    , suppliers_code_for_buyer( `10535908` )                      %PROD
	]) ]


%	, suppliers_code_for_buyer( `11202554` )   %TEST
%	, suppliers_code_for_buyer( `10535908` )   %PROD

	,[q0n(line), get_delivery_address ]
	
	, without_delivery_rule

	,[q0n(line), get_buyer_details ]

	,[contract_line, q0n(line), get_order_number ]

	, or([ [q0n(line), get_invoice_totals ], [ total_net(`0`), total_invoice(`0`) ] ])

%	, customer_comments( `Customer Comments` )
	,[q0n(line), customer_comments_line ] 

%	, shipping_instructions( `Shipping Instructions` )
	,[q0n(line), shipping_instructions_line ]

	,[q0n(line), delivery_date_line]

	, get_invoice_lines

%	, default_vat_rate(`19`)

] ).


%=======================================================================
i_line_rule( contract_line, [or([ [`Abruf`, `zu`, `Kontrakt`], `Bestellung`  ])  ]).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  get_delivery_header_line

	, get_delivery_party_line
	
	, q10( get_delivery_dept_line )

	, get_delivery_street_line

	, get_delivery_postcode_city_line
	 
] ).

%=======================================================================
i_line_rule( get_delivery_header_line, [
%=======================================================================
 
	 read_ahead(dummy(s1))
	 
	 , `Anlieferadresse`, `:`
	 
	 , check(dummy(y) < 325)

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
 
	  retab( [ -100 ] )
	   
	, delivery_dept(s1)

	, trace([ `delivery dept`, delivery_dept ])

] ).

%=======================================================================
i_line_rule( get_delivery_street_line, [
%=======================================================================
 
	delivery_street(s)

	, trace([ `delivery street`, delivery_street ])

] ).

%=======================================================================
i_line_rule( get_delivery_postcode_city_line, [
%=======================================================================
 
	q10([ loc_code(s) ])

	, delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(w)

	, trace([ `delivery city`, delivery_city ])

] ).

%=======================================================================
i_line_rule( without_delivery_rule, [
%=======================================================================
 
	without(delivery_party)
	
	, delivery_note_number(`20799550`)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_details, [ 
%=======================================================================

	get_buyer_header_line

	, get_buyer_contact

	, get_buyer_ddi

	, get_buyer_fax

	, get_buyer_email

] ).

%=======================================================================
i_line_rule( get_buyer_header_line, [ 
%=======================================================================

	q0n(anything)

	,`Sachbearbeiter`, `Einkauf`

	, trace([ `buyer details header found` ])

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(anything)

	, buyer_contact(s1)

	, check(buyer_contact(start) > 0 )

	, trace([ `buyer contact`, buyer_contact ])

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(anything)

	, `tel`, `+`, num(d)

	, set( regexp_cross_word_boundaries )

	, buyer_ddi(`0`)

	, append(buyer_ddi(w), ``, ``)

	, clear( regexp_cross_word_boundaries )

	, trace([ `buyer ddi`, buyer_ddi ])

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_fax, [ 
%=======================================================================

	q0n(anything)

	, `fax`, `+`, num(d)

	, set( regexp_cross_word_boundaries )

	, buyer_fax(`0`)

	, append(buyer_fax(w), ``, ``)

	, clear( regexp_cross_word_boundaries )

	, trace([ `buyer fax`, buyer_fax ])

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	q0n(anything)

	, buyer_email(s1)

	, check(buyer_email(start) > 0 )

	, trace([ `buyer email`, buyer_email ])

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

	get_order_number_header_line

	, get_order_number_line

] ).

%=======================================================================
i_line_rule( get_order_number_header_line, [ 
%=======================================================================

	`Bestellnummer`, `/`, `Datum`

	, trace( [ `order number header found` ] ) 

] ).

%=======================================================================
i_line_rule( get_order_number_line, [ 
%=======================================================================

	order_number(s), `/`

	, trace( [ `order number`, order_number ] )

	, invoice_date(d), `.`

	, or([ 
	
	 [`jan`, append(invoice_date(`01`), ` `, ``) ]
	,[`januar`, append(invoice_date(`01`), ` `, ``) ]
	
	,[`fab`, append(invoice_date(`02`), ` `, ``) ]
	,[`feb`, append(invoice_date(`02`), ` `, ``) ]
	,[`februar`, append(invoice_date(`02`), ` `, ``) ]

	,[`märz`, append(invoice_date(`03`), ` `, ``) ]
	,[`m`, `!`, `rz`, append(invoice_date(`03`), ` `, ``) ]
	,[`mär`, append(invoice_date(`03`), ` `, ``) ]
	,[`mar`, append(invoice_date(`03`), ` `, ``) ]
	,[`maerz`, append(invoice_date(`03`), ` `, ``) ]
	,[`m`, `!`, `r`, append(invoice_date(`03`), ` `, ``) ]

	,[ `april`, append(invoice_date(`04`), ` `, ``) ]
	,[ `apr`, append(invoice_date(`04`), ` `, ``) ]

	,[ `mai`, append(invoice_date(`05`), ` `, ``) ]

	,[ `juni`, append(invoice_date(`06`), ` `, ``) ]
	,[ `jun`, append(invoice_date(`06`), ` `, ``) ]

	,[ `juli`, append(invoice_date(`07`), ` `, ``) ]
	,[ `jul`, append(invoice_date(`07`), ` `, ``) ]

	,[ `august`, append(invoice_date(`08`), ` `, ``) ]
	,[ `aug`, append(invoice_date(`08`), ` `, ``) ]

	,[ `september`, append(invoice_date(`09`), ` `, ``) ]
	,[ `sept`, append(invoice_date(`09`), ` `, ``) ]
	,[ `sep`, append(invoice_date(`09`), ` `, ``) ]

	,[ `oktober`, append(invoice_date(`10`), ` `, ``) ]
	,[ `okt`, append(invoice_date(`10`), ` `, ``) ]

	,[ `november`, append(invoice_date(`11`), ` `, ``) ]
	,[ `nov`, append(invoice_date(`11`), ` `, ``) ]

	,[ `dezember`, append(invoice_date(`12`), ` `, ``) ] 
	,[ `dez`, append(invoice_date(`12`), ` `, ``) ] 

	])

	, q10(`.`), append(invoice_date(d), ` `, ``)

	, trace( [ `invoice date`, invoice_date ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_totals, [
%=======================================================================

	`Gesamtnettowert`, `ohne`, `Mwst`, `CHF`, tab

	, read_ahead(total_net(d))

	, trace( [ `total net`, total_net ] )

	, total_invoice(d), newline

	, trace( [ `total invoice`, total_invoice ] )

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
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ or([ get_invoice_line,  line ]) ] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `[`, `CHF`, `]`, tab, `[`, `CHF`, `]`,  newline ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or([ [`Hilti`, `(`, `Schweiz`, `)`]

	, [`Gesamtnettowert`, `ohne`, `Mwst`, `CHF`, tab] ])

] ).

%=======================================================================
i_line_rule( lines_line, [
%=======================================================================

	`_`, `_`, `_`, `_`, `_`, `_`, `_`, `_`

] ).

%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	get_invoice_values_line

	, q10(pack_line)

	, q10(lines_line)

	, or([ get_invoice_item_line, line_item(`missing`) ])

	, q10(lines_line)

	, q10(get_invoice_descr_line)

	, q10( [q(0,20,line), get_invoice_net_line ] )

	, q10(lines_line)

	, q10( or( [ get_invoice_date_line, [ with(invoice, delivery_date, DD), line_original_order_date(DD) ] ]) ) 

] ).

%=======================================================================
i_line_rule_cut( get_invoice_values_line, [
%=======================================================================

	line_order_line_number(w), tab

	, q10([ material(s), tab ])

	, line_quantity(d), tab

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(w)

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, newline

] ).


%=======================================================================
i_line_rule_cut( pack_line, [
%=======================================================================

	pack_num(d), uom(w)
	
	, newline

] ).

%=======================================================================
i_line_rule_cut( get_invoice_item_line, [
%=======================================================================

	`Ihre`, `Materialnummer`

	, or([ [ line_item(sf), or( [ `.`, `/` ] ), dummy(s) ], line_item(s) ])

	, trace([`line item`, line_item])

	, newline

] ).

%=======================================================================
i_line_rule_cut( get_invoice_descr_line, [
%=======================================================================

	line_descr(s1)

	, trace([`line descr`, line_descr])

	, newline

] ).

%=======================================================================
i_line_rule_cut( get_invoice_net_line, [
%=======================================================================

	`Nettowert`, `incl`, `Rab`, `.`, tab

	, einheit(s1), tab

	, unitamount(d), tab

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( get_invoice_date_line, [
%=======================================================================

	`Liefertermin`, tab

	, dummy(d), tab

	, uom(w), tab

	, line_original_order_date(d), q10(`.`)

	, or([ [`jan`, append(line_original_order_date(`01`), ` `, ``) ]

	,[`fab`, append(line_original_order_date(`02`), ` `, ``) ]

	,[`märz`, append(line_original_order_date(`03`), ` `, ``) ]
	,[`m`, `!`, `rz`, append(line_original_order_date(`03`), ` `, ``) ]
	,[`mär`, append(line_original_order_date(`03`), ` `, ``) ]
	,[`m`, `!`, `r`, append(line_original_order_date(`03`), ` `, ``) ]

	,[ `april`, append(line_original_order_date(`04`), ` `, ``) ]
	,[ `apr`, append(line_original_order_date(`04`), ` `, ``) ]

	,[ `mai`, append(line_original_order_date(`05`), ` `, ``) ]

	,[ `juni`, append(line_original_order_date(`06`), ` `, ``) ]
	,[ `jun`, append(line_original_order_date(`06`), ` `, ``) ]

	,[ `juli`, append(line_original_order_date(`07`), ` `, ``) ]
	,[ `jul`, append(line_original_order_date(`07`), ` `, ``) ]

	,[ `august`, append(line_original_order_date(`08`), ` `, ``) ]
	,[ `aug`, append(line_original_order_date(`08`), ` `, ``) ]

	,[ `september`, append(line_original_order_date(`09`), ` `, ``) ]
	,[ `sept`, append(line_original_order_date(`09`), ` `, ``) ]
	,[ `sep`, append(line_original_order_date(`09`), ` `, ``) ]

	,[ `oktober`, append(line_original_order_date(`10`), ` `, ``) ]
	,[ `okt`, append(line_original_order_date(`10`), ` `, ``) ]

	,[ `november`, append(line_original_order_date(`11`), ` `, ``) ]
	,[ `nov`, append(line_original_order_date(`11`), ` `, ``) ]

	,[ `dezember`, append(line_original_order_date(`12`), ` `, ``) ] 
	,[ `dez`, append(line_original_order_date(`12`), ` `, ``) ] 

	])

	, q10(`.`), append(line_original_order_date(d), ` `, ``)

	, trace( [ `line original order date `, line_original_order_date ] )


] ).


%=======================================================================
i_line_rule_cut( delivery_date_line, [
%=======================================================================

	`Liefertermin`, tab, `:`

	, delivery_date(d), q10(`.`)

	, or([ [`jan`, append(delivery_date(`01`), ` `, ``) ]

	,[`fab`, append(delivery_date(`02`), ` `, ``) ]

	,[`märz`, append(delivery_date(`03`), ` `, ``) ]
	,[`m`, `!`, `rz`, append(delivery_date(`03`), ` `, ``) ]
	,[`mär`, append(delivery_date(`03`), ` `, ``) ]
	,[`m`, `!`, `r`, append(delivery_date(`03`), ` `, ``) ]

	,[ `april`, append(delivery_date(`04`), ` `, ``) ]
	,[ `apr`, append(delivery_date(`04`), ` `, ``) ]

	,[ `mai`, append(delivery_date(`05`), ` `, ``) ]

	,[ `juni`, append(delivery_date(`06`), ` `, ``) ]
	,[ `jun`, append(delivery_date(`06`), ` `, ``) ]

	,[ `juli`, append(delivery_date(`07`), ` `, ``) ]
	,[ `jul`, append(delivery_date(`07`), ` `, ``) ]

	,[ `august`, append(delivery_date(`08`), ` `, ``) ]
	,[ `aug`, append(delivery_date(`08`), ` `, ``) ]

	,[ `september`, append(delivery_date(`09`), ` `, ``) ]
	,[ `sept`, append(delivery_date(`09`), ` `, ``) ]
	,[ `sep`, append(delivery_date(`09`), ` `, ``) ]

	,[ `oktober`, append(delivery_date(`10`), ` `, ``) ]
	,[ `okt`, append(delivery_date(`10`), ` `, ``) ]

	,[ `november`, append(delivery_date(`11`), ` `, ``) ]
	,[ `nov`, append(delivery_date(`11`), ` `, ``) ]

	,[ `dezember`, append(delivery_date(`12`), ` `, ``) ] 
	,[ `dez`, append(delivery_date(`12`), ` `, ``) ] 

	])

	, q10(`.`), append(delivery_date(d), ` `, ``)

	, trace([`delivery date`, delivery_date])

] ).

