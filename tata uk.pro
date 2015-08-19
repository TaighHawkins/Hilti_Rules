%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - TATA HILTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( tata_hilti, `05 June 2015` ).

%i_pdf_parameter( direct_object_mapping, 0 ).


i_date_format( _ ).

%i_supplier_rule([ peek_fails( [ q(0, 5, line), amendment_line ]) ]).

i_line_rule( amendment_line, [ q0n(anything), or([ `cancellation`, `amendment` ]) ]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `GB-TATASTL` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, type_of_supply(`01`)
	, cost_centre(`Standard`)

	, get_order_number

	, get_order_date

	, get_buyer_ddi

	, get_buyer_fax

	, get_buyer_email

	, [ without(buyer_contact), get_buyer_contact ]

	, or([ get_delivery_contact,  set_default_contact ])

	, or([ lookup_delivery_details, [ get_partn_code, get_delivery_details ]])

	, get_invoice_lines 

	, [qn0(line), invoice_total_line ]

	, [qn0(line), total_net_line ]

	, [ q(0,5,line), amendment_line, invoice_type(`ZE`)]

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( set_default_contact, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	with(invoice, buyer_contact, BC), delivery_contact(BC) 

	,  trace( [ `Delivery contact set to buyer contact`, delivery_contact] )


] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( lookup_delivery_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	q(1,10,line), buyer_postcode_line, trace( [ `buyer postcode`, buyer_postcode] )

	, q0n(line), delivery_start_header_line

	, invoice_to_street_line, trace( [ `invoice to street`, invoice_to_street] )

	, q(1,10,line), invoice_to_postcode_line, trace( [ `invoice to postcode`, invoice_to_postcode] )

	, check( i_user_check( get_tata_lookup, buyer_postcode, AG_PARTN, invoice_to_street, invoice_to_postcode, WE_PARTN) )

	, suppliers_code_for_buyer(AG_PARTN), trace( [ `AG PARTN`, suppliers_code_for_buyer] )

	, delivery_note_number(WE_PARTN), trace( [ `WE PARTN`, delivery_note_number] )


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_partn_code, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	q(1,10,line), buyer_postcode_line, trace( [ `buyer postcode`, buyer_postcode] )

	, check( i_user_check( get_tata_lookup, buyer_postcode, AG_PARTN, WE_STRS, WE_POSTCODE, WE_PARTN) )

	, suppliers_code_for_buyer(AG_PARTN), trace( [ `AG PARTN`, suppliers_code_for_buyer] )


] ).



%=======================================================================
i_line_rule( buyer_postcode_line, [ buyer_postcode(pc) ]).
%=======================================================================
i_line_rule( buyer_postcode_line, [ `BRIGG`, `ROAD`, buyer_postcode(`DN161BP`) ]).
%=======================================================================
i_line_rule( invoice_to_postcode_line, [ invoice_to_postcode(pc) ]).
%=======================================================================
i_line_rule_cut( invoice_to_street_line, [ invoice_to_street(s) ]).
%=======================================================================



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_delivery_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	gen1_address_details_without_names( [ delivery_left_margin, delivery_start_rule,
					delivery_street, delivery_street, delivery_city, delivery_state_x, delivery_postcode,
					delivery_end_line ] )


	, q10( [ with( my_delivery_street )
		, check( i_user_check( gen_same, my_delivery_street, DEL_STR ) ), delivery_street( DEL_STR ) ] )

] ).

%=======================================================================
i_rule( delivery_start_rule, [ 
%=======================================================================

	delivery_start_header_line

	, q10(delivery_street_line), q01(line), delivery_party_line, up

	, delivery_start_line

] ).

%=======================================================================
i_line_rule( delivery_start_header_line, [ 
%=======================================================================

	`delivery`, `address`, `:`	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( delivery_start_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	read_ahead( delivery_left_margin )

	, dummy(s)	

	, check( i_user_check( gen1_store_address_margin( delivery_left_margin ), delivery_left_margin(start), 5, 5 ) )
	
] ).

%=======================================================================
i_line_rule( delivery_end_line, [ 
%=======================================================================

	or( [ with(delivery_postcode)

	, [`incoterms`, `:` ]

	] )

] ).

%=======================================================================
i_rule( get_delivery_address_line, [ 
%=======================================================================

	delivery_address_line_header_line

	, delivery_address_line_line

] ).

%=======================================================================
i_line_rule( delivery_address_line_header_line, [ 
%=======================================================================

	`delivery`, `address`, `:`, newline

] ).

%=======================================================================
i_line_rule( delivery_address_line_line, [ 
%=======================================================================

	delivery_address_line(s1), newline

	, trace( [ `delivery address line`, delivery_address_line] )

]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	my_delivery_street(s1), newline

	, trace( [ `my delivery street`, my_delivery_street] )

]).



%=======================================================================
i_rule( get_delivery_party, [ 
%=======================================================================

	delivery_party_header_line

	, line

	, delivery_party_line

] ).

%=======================================================================
i_line_rule( delivery_party_header_line, [ 
%=======================================================================

	`delivery`, `address`, `:`, newline

] ).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	peek_ahead(`tata`), delivery_party(s1), newline

	, trace( [ `delivery party`, delivery_party] )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	q0n(line)

	, order_date_header_line

	, q01(line)

	, order_date_line

] ).

%=======================================================================
i_line_rule( order_date_header_line, [ 
%=======================================================================

	q0n(anything)

	, `date`, newline

] ).

%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================

	q0n(anything)

	, invoice_date(date), newline

	, trace( [ `invoice date`, invoice_date] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	q0n(line)

	, order_number_header_line

	, q01(line)

	, order_number_line

] ).

%=======================================================================
i_line_rule( order_number_header_line, [ 
%=======================================================================

	q0n(anything)

	, `order`, `number`, newline

] ).

%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================

	q0n(anything)

	, order_number(s1)

	, newline

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(line)

	, buyer_contact_header_line

	, q01(line)

	, buyer_contact_line

] ).

%=======================================================================
i_line_rule( buyer_contact_header_line, [ 
%=======================================================================

	q0n(anything)

	, `buyer`

	, newline	

] ).

%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	q0n(anything)

	, buyer_contact(s1)

	, check(buyer_contact(start) > 0)

	, trace( [ `buyer contact`, buyer_contact ] ) 

] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(line)

	, buyer_ddi_header_line

	, q01(line)

	, buyer_ddi_line

] ).

%=======================================================================
i_line_rule( buyer_ddi_header_line, [ 
%=======================================================================

	q0n(anything)

	, `telephone`

	, newline	

] ).

%=======================================================================
i_line_rule( buyer_ddi_line, [ 
%=======================================================================

	q0n(anything)

	, buyer_ddi(s1)

	, check(buyer_ddi(start) > 0)

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).

%=======================================================================
i_rule( get_buyer_fax, [ 
%=======================================================================

	q0n(line)

	, buyer_fax_header_line

	, q01(line)

	, buyer_fax_line

] ).

%=======================================================================
i_line_rule( buyer_fax_header_line, [ 
%=======================================================================

	q0n(anything)

	, `fax`

	, newline	

] ).

%=======================================================================
i_line_rule( buyer_fax_line, [ 
%=======================================================================

	q0n(anything)

	, buyer_fax(s1)

	, check(buyer_fax(start) > 0)

	, trace( [ `buyer fax`, buyer_fax ] ) 

] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	q0n(line)

	, buyer_email_header_line

	, q01(line)

	, buyer_email_line

] ).

%=======================================================================
i_line_rule( buyer_email_header_line, [ 
%=======================================================================

	q0n(anything)

	, `email`, `address`

	, newline	

] ).

%=======================================================================
i_line_rule( buyer_email_line, [ 
%=======================================================================

	q0n(anything)

	, read_ahead( buyer_email(s1) )

	, check(buyer_email(start) > 0)

	, trace( [ `buyer email`, buyer_email ] ) 

	, q10([ buyer_contact(s), `.`, append(buyer_contact(w), ` `, ``), `@`  

	, trace( [ `buyer contact from email`, buyer_contact ] ) ])


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( get_delivery_contact, [ 
%=======================================================================

	q0n(line)

	, delivery_contact_line

	, q10(delivery_contact_email_line)

] ).

%=======================================================================
i_line_rule_cut( delivery_contact_line, [ 
%=======================================================================

	q0n(anything)

	, or([ [`non`, `-`, `commercial`, `contact`], `fao` ])

	, or([ [delivery_contact(w), q0n(anything), append(delivery_contact(w), ` `, ``), `:`], delivery_contact(s1) ])

	, q10([ read_ahead([q0n(anything), `@` ])

	, delivery_email(s1) ])

	, trace( [ `delivery contact`, delivery_contact ] ) 

	, trace( [ `delivery email`, delivery_email ] ) 

] ).

%=======================================================================
i_line_rule_cut( delivery_contact_email_line, [ 
%=======================================================================

	without(delivery_email)

	, read_ahead( [q0n(word), `@` ])

	, delivery_email(s1)

	, trace( [ `delivery email`, delivery_email ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================
		
	`total`, `net`, `value`, `excl`, `.`, `vat`

	, q0n(anything)

	, total_invoice(d)
	
	, newline

	, trace( [ `invoice total`, total_invoice ] )

]).

%=======================================================================
i_line_rule( total_net_line, [
%=======================================================================
		
	`total`, `net`, `value`, `excl`, `.`, `vat`

	, q0n(anything)

	, total_net(d)
	
	, newline

	, trace( [ `invoice net`, total_net ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)

	, or( [ [ get_line_invoice, q10( get_line_description ), q0n( [ peek_fails( or( [ get_line_invoice, line_end_line ] ) ), line ] ), product_code_line,  clear( unfinished )  ]

 			, [ get_line_invoice, set( unfinished ), q10( get_line_description ) ]

			, [ test( unfinished ), product_code_line, clear( unfinished ) ]

 			, line
		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	or( [ [`the`, `item`, `covers`, `the`, `following`, `services`, `:` ]

		, [`no`, `.`, tab, `qty` ]

	])

] ).

%=======================================================================
i_line_rule_cut( product_code_line, [ 
%=======================================================================

	q0n(word)

	, or([ `hilti`, `stock`, `part`, `catalogue`, `ref`,  `reference`, `cat` , `code`, `material`, `your`, `product`, [`p`, `/`, `n`] ]) 

	, q0n(word)

	, or([ line_item( f([begin, q(dec,6,8), end]) ), [ line_item( f([begin, q(dec,3,8), end]) ), or([ tab, newline ]) ] ])

	, trace( [`line item`, line_item] )


] ).

%=======================================================================
i_line_rule_cut( line_header_line_2, [ q0n(anything), `by`, tab, `(`, `excl`, `vat`, `)`, newline ] ).
%=======================================================================

%=======================================================================
i_line_rule( line_continuation_line, [ append(line_descr(s1), ` `,``), or([newline, tab]) ]).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [ or([ [`page`, word, `of`], [`total`, `net`, `value`, `excl`, `.`, `vat`] ]) ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( get_line_invoice, [
%=======================================================================

	line_order_line_number(w1), tab

	, trace( [`line order line number`, line_order_line_number] )

	, line_quantity(d) 

	, trace( [`line quantity`, line_quantity] )

	, q10( [ tab, line_item_for_buyer(s1), trace( [`Buyer line item`, line_item_for_buyer] )

		, check(line_item_for_buyer(start) < -150) ])

	, tab

	, peek_fails(`PE`), peek_fails(`MON`)

	, line_quantity_uom_code(w1), check(line_quantity_uom_code(start) > -100) 

	, qn0(anything)

	, tab, line_net_amount(d)

	, trace( [`line net amount`, line_net_amount] )

	, with(invoice, invoice_date, ID), line_original_order_date(ID)

	, newline

] ).

%=======================================================================
i_line_rule_cut( get_line_description, [
%=======================================================================

	line_descr(s1)

	, check(line_descr(start) < -400)

	, trace( [`line description`, line_descr] )

] ).


i_op_param( xml_empty_tags( `line_item` ), _, _, _, `MISSING` ).


i_user_check( get_tata_lookup, AG_PC, AG_CODE, WE_STRS, WE_PC, WE_CODE ) :- 

	( grammar_set( test_flag )

	-> tata_lookup_test( AG_PC, AG_CODE, WE_STRS, WE_PC, WE_CODE )

	; tata_lookup( AG_PC, AG_CODE, WE_STRS, WE_PC, WE_CODE ) ).


tata_lookup( `DN161BP`, `18759698`, `Central Stores`, `TS252EG`, `15353863` ).
tata_lookup( `DN161BP`, `18759698`, `Central Stores`, `TS252EF`, `15364361` ).
tata_lookup( `DN161BP`, `18759698`, `General Stores`, `SA132NG`, `12240620` ).
tata_lookup( `DN161BP`, `18759698`, `General Stores`, `S362JA`, `19093385` ).
tata_lookup( `DN161BP`, `18759698`, `Central Stores`, `NP194QZ`, `12240635` ).
tata_lookup( `DN161BP`, `18759698`, `Coke Oven Stores`, `DN161AR`, `18208807` ).
tata_lookup( `DN161BP`, `18759698`, `Dalzell`, `ML11PU`, `12287712` ).
tata_lookup( `DN161BP`, `18759698`, `Steelmaking Mould Bay`, `DN163RL`, `20456456` ).
tata_lookup( `DN161BP`, `18759698`, `BBM Main Fitting Shop`, `DN163RL`, `20805704` ).
tata_lookup( `DN161BP`, `18759698`, `Central Stores`, `NN175UA`, `20816030` ).
tata_lookup( `DN161BP`, `18759698`, `Bloom and Billet Mill Stores`, `DN163RL`, `18699482` ).
tata_lookup( `DN161BP`, `18759698`, `Aldwarke Melting Shop Offices`, `S653ES`, `20870403` ).
tata_lookup( `DN161BP`, `18759698`, `Teesside Beam Mill`, `TS105QW`, `21145670` ).
tata_lookup( `DN161BP`, `18759698`, `Catnic - Goods Inwards`, `CF833GL`, `21053880` ).
tata_lookup( `DN161BP`, `18759698`, `Central Stores`, `CH52NH`, `20970781` ).
tata_lookup( `DN161BP`, `18759698`, `CP&P 7 Bay West`, `CH52NH`, `21135575` ).
tata_lookup( `DN161BP`, `18759698`, `General Stores`, `SA149SD`, `21292375` ).
tata_lookup( `DN161BP`, `18759698`, `Thrybergh Bar Mill Main Office`, `S653ES`, `21327836` ).
tata_lookup( `DN161BP`, `18759698`, `General Stores`, `NP190RB`, `21350672` ).
tata_lookup( `DN161BP`, `18759698`, `Port Talbot Engineering Stores`, `SA132NG`, `21725857` ).

tata_lookup( `SA132NG`, `12240972`, `Central Stores`, `NP194QZ`, `12240608` ).
tata_lookup( `SA132NG`, `12240972`, `Plate Processing Centre Cradley`, `B632RN`, `20117441` ).
tata_lookup( `SA132NG`, `12240972`, `Central Stores`, `CH52NH`, `12240639` ).
tata_lookup( `SA132NG`, `12240972`, `Central Stores`, `NN175UA`, `20784405` ).
tata_lookup( `SA132NG`, `12240972`, `General Stores`, `NP190RB`, `18626140` ).
tata_lookup( `SA132NG`, `12240972`, `Structural Dept Stores`, `DN161AR`, `21167697` ).
tata_lookup( `SA132NG`, `12240972`, `Central Stores`, `TS252EF`, `21265648` ).
tata_lookup( `SA132NG`, `12240972`, `Fabstock Long Products Service Cen`, `WV113SQ`, `21300905` ).
tata_lookup( `SA132NG`, `12240972`, `Re Melted Steels`, `S362JA`, `21461438` ).
tata_lookup( `SA132NG`, `12240972`, `Catnic - Goods Inwards`, `CF833GL`, `21475071` ).
tata_lookup( `SA132NG`, `12240972`, `DAZELL`, `ML11PU`, `21519217` ).

tata_lookup( `S601DW`, `12292448`, `Re Melted Steels`, `S362JA`, `12292449` ).
tata_lookup( `S601DW`, `12292448`, `Aldwarke Melting Shop Offices`, `S653ES`, `18681397` ).
tata_lookup( `S601DW`, `12292448`, `General Stores`, `S362JA`, `20000993` ).
tata_lookup( `S601DW`, `12292448`, `Central Stores`, `WS109LL`, `19616004` ).
tata_lookup( `S601DW`, `12292448`, `Central Stores`, `TS252EF`, `20808151` ).
tata_lookup( `S601DW`, `12292448`, `Central Stores`, `TS252EG`, `21146516` ).

tata_lookup( `WV113SQ`, `20097725`, `Catnic - Goods Inwards`, `CF833GL`, `19109432` ).
tata_lookup( `WV113SQ`, `20097725`, `Teesside Beam Mill Offices`, `TS105QW`, `20720278` ).
tata_lookup( `WV113SQ`, `20097725`, `Leeds Strip Processing Reception`, `LS124DH`, `20098345` ).
tata_lookup( `WV113SQ`, `20097725`, `A11 East Amenity`, `NP194QZ`, `20098396` ).
tata_lookup( `WV113SQ`, `20097725`, `Service Centre Caldicot`, `NP265PW`, `20098397` ).
tata_lookup( `WV113SQ`, `20097725`, `Sheet Centre Llanwern`, `NP194QZ`, `20815366` ).

tata_lookup( `TS105QW`, `18639184`, `Teesside Beam Mill`, `TS105QW`, `18639184` ).
tata_lookup( `TS105QW`, `18639184`, `Central Stores`, `TS252EG`, `20792185` ).
tata_lookup( `TS105QW`, `18639184`, `General Stores`, `TS134EG`, `20964725` ).
tata_lookup( `TS105QW`, `18639184`, `Central Stores`, `TS252EF`, `21185192` ).

tata_lookup( `SA149SD`, `21063592`, `Central Stores`, `NP194QZ`, `21063617` ).
tata_lookup( `SA149SD`, `21063592`, `Port Talbot Engineering Stores`, `SA132NG`, `21079268` ).






tata_lookup_test( `DN161BP`, `11234947`, `Central Stores`, `TS252EG`, `11234942`).
tata_lookup_test( `DN161BP`, `11234947`, `Central Stores`, `TS252EF`, `11234943`).
tata_lookup_test( `DN161BP`, `11234947`, `General Stores`, `SA132NG`, `11234944`).
tata_lookup_test( `DN161BP`, `11234947`, `General Stores`, `S362JA`, `11234950`).
tata_lookup_test( `DN161BP`, `11234947`, `Central Stores`, `NP194QZ`, `11234951`).
tata_lookup_test( `DN161BP`, `11234947`, `Coke Oven Stores`, `DN161AR`, `11234952`).
tata_lookup_test( `DN161BP`, `11234947`, `Dalzell`, `ML11PU`, `11234953`).
tata_lookup_test( `DN161BP`, `11234947`, `Steelmaking Mould Bay`, `DN163RL`, `11234954`).
tata_lookup_test( `SA132NG`, `11234781`, `Central Stores`, `NP194QZ`, `11234955`).
tata_lookup_test( `SA132NG`, `11234781`, `Plate Processing Centre Cradley`, `B632RN`, `20117441`).
tata_lookup_test( `SA132NG`, `11234781`, `Central Stores`, `CH52NH`, `11234956`).
tata_lookup_test( `SA132NG`, `11234781`, `Central Stores`, `NN175UA`, `11234957`).
tata_lookup_test( `S601DW`, `11234948`, `Re Melted Steels`, `S362JA`, `11234958`).
tata_lookup_test( `S601DW`, `11234948`, `Aldwarke Melting Shop Offices`, `S653ES`, `11234959`).
tata_lookup_test( `S601DW`, `11234948`, `General Stores`, `S362JA`, `11234960`).
tata_lookup_test( `S601DW`, `11234948`, `Central Stores`, `WS109LL`, `11234961`).
tata_lookup_test( `WV113SQ`, `11234949`, `Catnic - Goods Inwards`, `CF833GL`, `11234962`).
tata_lookup_test( `WV113SQ`, `11234949`, `Teesside Beam Mill Offices`, `TS105QW`, `11234963`).
tata_lookup_test( `WV113SQ`, `11234949`, `Leeds Strip Processing Reception`, `LS124DH`, `11234964`).
tata_lookup_test( `WV113SQ`, `11234949`, `A11 East Amenity`, `NP194QZ`, `11234965`).