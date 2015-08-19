%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FILL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fill, `08 July 2014` ).

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
	    , suppliers_code_for_buyer( `10040762` )                      %PROD
	]) ]

%	, shipping_instructions( `Shipping Instructions` )
	,[q0n(line), shipping_instructions_line ]

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

	,[q0n(line), get_order_date ]

%	, customer_comments( `Customer Comments` )
	,[q0n(line), customer_comments_line ] 

	, get_invoice_lines

	,[q0n(line), get_invoice_totals ]
	
	, clear_the_address

] ).

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

	, q10(get_delivery_address_line)

	, get_delivery_street_line

	, get_delivery_postcode_city_line
	 
] ).

%=======================================================================
i_line_rule( get_delivery_header_line, [
%=======================================================================
 
	 `lieferadresse`, `:`, newline

	, trace([ `delivery header found ` ])

] ).

%=======================================================================
i_line_rule( get_delivery_party_line, [
%=======================================================================
 
	delivery_party(s1)

	, trace([ `delivery party`, delivery_party ])

	, newline 

] ).

%=======================================================================
i_line_rule( get_delivery_address_line, [
%=======================================================================
 
	delivery_address_line(s)

	, trace([ `delivery address line`, delivery_address_line ])

	, newline 

] ).

%=======================================================================
i_line_rule( get_delivery_street_line, [
%=======================================================================
 
	delivery_street(s)

	, trace([ `delivery street`, delivery_street ])

	, newline 

] ).

%=======================================================================
i_line_rule( get_delivery_postcode_city_line, [
%=======================================================================
 
	post(w)

	, or( [ [ without( delivery_note_number ), `4921`, delivery_postcode( `4921` ), delivery_note_number( `10040762` ), set( clear_address ) ]
	
		, delivery_postcode(d)
	
	] )

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s)

	, trace([ `delivery city`, delivery_city ])

	, newline 

] ).

%=======================================================================
i_rule( clear_the_address, [
%=======================================================================
 
	  test( clear_address )
	  
	, remove( delivery_party )
	
	, remove( delivery_address_line )
	
	, remove( delivery_street )
	
	, remove( delivery_postcode )
	
	, remove( delivery_city )
	
	, trace( [ `Address wiped` ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`Bearbeitung`, `Einkauf`, `:`, tab

	, read_ahead([ dummy(w), buyer_contact(w) ]), append(buyer_contact(w), ` `, ``), name(w)

	, trace([ `buyer contact`, buyer_contact ])

	, tab

	, or([ [ `+`, country_code(w), wrap(buyer_ddi(s1), `0`, ``) ], buyer_ddi(s1) ])

	, trace([ `buyer ddi`, buyer_ddi ])

	, tab

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

	`Bearbeitung`, `Technik`, `:`, tab

	, read_ahead([ dummy(w), delivery_contact(w) ]), append(delivery_contact(w), ` `, ``), name(w)

	, trace([ `delivery contact`, delivery_contact ])

	, tab

	, or([ [ `+`, country_code(w), wrap(delivery_ddi(s1), `0`, ``) ], delivery_ddi(s1) ])

	, trace([ `delivery ddi`, delivery_ddi ])

	, q10([ tab, delivery_email(s) ])

	, trace([ `delivery email`, delivery_email ])

	, newline

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

	,`Bestellung`, `:`, tab

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

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

	q0n(anything)

	,`Bestelldatum`, `:`
	
	, invoice_date(date)

	, trace( [ `invoice date`, invoice_date] )

	, newline

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( customer_comments_line, [ 
%=======================================================================

	customer_comments_header_line

	, q(0, 2, line), customer_comments_line1

	, q10([ line, customer_comments_line2 ])

]).

%=======================================================================
i_line_rule( customer_comments_header_line, [ 
%=======================================================================

	`fixer`, `liefertermin`, `:`

	, trace( [ `customer comments header found` ] )

]).

%=======================================================================
i_line_rule( customer_comments_line1, [ 
%=======================================================================

	read_ahead(dummy(s))

	, check(dummy(end) < 70 )
	
	, customer_comments(s1)

	, check(customer_comments(end) < 65 )

	, trace( [ `customer comments`, customer_comments ] )

]).

%=======================================================================
i_line_rule( customer_comments_line2, [ 
%=======================================================================

	read_ahead(dummy(s)), check(dummy(end) < 65 )

	, append(customer_comments(s), ` `, ``)

	, trace( [ `customer comments`, customer_comments ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( shipping_instructions_line, [ 
%=======================================================================

	shipping_instructions_header_line

	, q(0, 2, line), shipping_instructions_line1

	, q10([ line , shipping_instructions_line2 ])

	, q10( lookup_shipping_instructions )
	
]).

%=======================================================================
i_line_rule( shipping_instructions_header_line, [ 
%=======================================================================

	`fixer`, `liefertermin`, `:`

	, trace( [ `shipping instructions header found` ] )

]).

%=======================================================================
i_line_rule( shipping_instructions_line1, [ 
%=======================================================================

	read_ahead(dummy(s))

	, check(dummy(end) < 70 )
	
	, shipping_instructions(s1)

	, check(shipping_instructions(end) < 65 )

	, trace( [ `shipping instructions `, shipping_instructions ] )

]).

%=======================================================================
i_line_rule( shipping_instructions_line2, [ 
%=======================================================================

	read_ahead(dummy(s)), check(dummy(end) < 65 )

	, append(shipping_instructions(s), ` `, ``)

	, trace( [ `shipping instructions `, shipping_instructions ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	q0n(line), total_net_line

%	, q0n(line), total_vat_line

	, q0n(line), total_invoice_line

] ).

%=======================================================================
i_line_rule( total_net_line, [
%=======================================================================

	`Zwischensumme`, `:`, tab, `EUR`, tab

	, total_net(d), newline

	, trace( [ `total net`, total_net ] )

] ).

%=======================================================================
i_line_rule( total_vat_line, [
%=======================================================================

	`+`, `20`, `,`, `00`, `MwSt`, tab, `EUR`, tab

	, total_vet(d), newline

	, trace( [ `total vat`, total_vat ] )

] ).

%=======================================================================
i_line_rule( total_invoice_line, [
%=======================================================================

	`Gesamtbetrag`, tab, `EUR`, tab

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

		, or([ get_invoice_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, tab, `Bezeichnung`, tab, `Material` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or([ [`Zwischensumme`, `:`, tab, `EUR`, tab]
		, [`e`, `-`, `mail`, `:`]
		, [ `Pos`, `.`, tab, `Bezeichnung` ]
		])
] ).

%=======================================================================
i_rule( get_invoice_line, [
%=======================================================================

	get_invoice_values_line

	, q10(append_descr_line)

	, get_invoice_second_line

	, get_invoice_third_line
	
] ).

%=======================================================================
i_line_rule( get_invoice_values_line, [
%=======================================================================

	line_order_line_number(w)

	, line_descr(s1), tab

	, trace([`line descr`, line_descr ])

	, line_quantity(d)

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(w1)

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, qn0(anything), tab

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount ])

	, newline

] ).

%=======================================================================
i_line_rule( append_descr_line, [
%=======================================================================

	append(line_descr(s), ` `, ``), newline

] ).

%=======================================================================
i_line_rule( get_invoice_second_line, [
%=======================================================================

	`liefertermin`, `:`

	, line_original_order_date(date), tab

	, trace([`line original order date`, line_original_order_date ])

	, `Art`, `.`, `Nr`, `.`, `Lief`, `.`, `:`, tab

	, line_item(s1)

	, trace([`line item`, line_item ])

	, tab, rabatt(s)

	, newline

] ).

%=======================================================================
i_line_rule( get_invoice_third_line, [
%=======================================================================

	q0n(anything)

	,`Art`, `.`, `Nr`, `.`, `FILL`, `:`, tab

	, line_item_for_buyer(s1)

	, trace([`line item for buyer`, line_item_for_buyer ])

	, tab, num(d)

	, newline

] ).

%=======================================================================
i_rule( lookup_shipping_instructions, [
%=======================================================================

    with( invoice, shipping_instructions, SHIP )

	, trace( [ `SHIP`, SHIP ] )

    , check( i_user_check( lookup_delivery_note, SHIP, NOTE ) )

    , delivery_note_number( NOTE )
    
    , trace( [ `looked up delivery_note_number`, delivery_note_number ] )
	
	, set( clear_address )
] ).

%=======================================================================
i_user_check( lookup_delivery_note, Ship, Note )
%-----------------------------------------------------------------------
:- delivery_note_table( Word, Note ), string_to_lower( Ship, Lower_ship ), q_sys_sub_string( Lower_ship, _, _, Word ).
%=======================================================================

delivery_note_table(`holzhafen`,`18081848`).
delivery_note_table(`fronius`,`18117486`).
delivery_note_table(`silbermöwe`,`19925146`).
delivery_note_table(`rathaus münchen`,`20832780`).
delivery_note_table(`big biz`,`20938033`).
delivery_note_table(`westminster`,`21583731`).

