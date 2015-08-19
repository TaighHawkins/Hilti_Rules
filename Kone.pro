%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - KONE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( kone, `27 May 2015` ).

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

	%, currency( `4400` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10321767` ) ]    %TEST
	    , suppliers_code_for_buyer( `18670625` )                      %PROD
	]) ]

%	, customer_comments( `Customer Comments` )
	, or( [ [ q0n(line), customer_comments_line ] , customer_comments( `` ) ])

%	, shipping_instructions( `Shipping Instructions` )
	, shipping_instructions( `` )

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_fax ]

	, get_invoice_lines

	, [qn0(line), get_totals ]

	,[ q0n(line), get_shipping_instructions]


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

	, q01(line)

	 , delivery_party_line

	, q01(line)

	, q10(shipping_instructions_rule)

	, q(0,3,line)

	 , delivery_street_line

	, q01(line)

	 , delivery_postcode_and_city

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`Lieferanschrift`

	, trace([ `delivery header found` ])
	

]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	 delivery_party(s)

	, q10([ tab, read_ahead([dummy(s), check(dummy(end) < -210)]), append(delivery_party(s1), ` `, ``) ])

	, check(delivery_party(start) < -400 )

	, trace([ `delivery party`, delivery_party ])
	

]).

%=======================================================================
i_rule( shipping_instructions_rule, [ 
%=======================================================================

	 or([ [shipping_instructions_line, shipping_instructions_line_2 ], shipping_instructions_line ])
	

]).


%=======================================================================
i_line_rule( shipping_instructions_line, [ 
%=======================================================================

	 read_ahead(shipping_instructions(s1))

	, check(shipping_instructions(start) < -400 )

	, customer_comments(s1)

	, trace([ `shipping instructions`, shipping_instructions ])
	

]).


%=======================================================================
i_line_rule( shipping_instructions_line_2, [ 
%=======================================================================

	 read_ahead(shipping_instructions_2(s1))

	, check(shipping_instructions_2(start) < -400 )

	, read_ahead([ append(customer_comments(s1), ` `,``) ] )

	, append(shipping_instructions(s1), ` `,``)

	, trace([ `shipping instructions`, shipping_instructions ])
	

]).



%=======================================================================
i_line_rule( shipping_instructions_line_2, [ 
%=======================================================================

	 read_ahead(shipping_instructions(s1))

	, check(shipping_instructions(start) < -400 )

	, customer_comments(s1)

	, trace([ `shipping instructions`, shipping_instructions ])
	

]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	 delivery_street(s)

	, check(delivery_street(start) < -400 )

	, trace([ `delivery street`, delivery_street ])
	

]).

%=======================================================================
i_line_rule( delivery_postcode_and_city, [ 
%=======================================================================

	 delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s)

	, check(delivery_city(start) < -300 )

	, trace([ `delivery city`, delivery_city ])
	

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  invoice_date_header_line

	, q(0, 2, line), get_invoice_date_line

] ).

%=======================================================================
i_line_rule( invoice_date_header_line, [ 
%=======================================================================

	q0n(anything)

	, `gedruckt`

	, trace([ `invoice date header found` ])

] ).

%=======================================================================
i_line_rule( get_invoice_date_line, [ 
%=======================================================================

	q0n(anything)

	, invoice_date(date)

	, check(invoice_date(start) > 280 )

	, trace([ `invoice date`, invoice_date ])

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

	, q(0, 2, line), get_order_number_line

] ).

%=======================================================================
i_line_rule( order_number_header_line, [ 
%=======================================================================

	q0n(anything)

	, `bestellnummer`

	, trace([ `order number header found` ])

] ).

%=======================================================================
i_line_rule( get_order_number_line, [ 
%=======================================================================

	q0n(anything)

	, order_number(s)

	, check(order_number(start) > 0 )

	, trace([ `order number`, order_number ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  buyer_contact_header_line

	, q(0, 2, line), get_buyer_contact_line

] ).

%=======================================================================
i_line_rule( buyer_contact_header_line, [ 
%=======================================================================

	q0n(anything)

	, `kontakt`

	, trace([ `buyer contact header found` ])

] ).

%=======================================================================
i_line_rule( get_buyer_contact_line, [ 
%=======================================================================

	q0n(anything)

	, buyer_contact(s), tab

	, check(buyer_contact(start) > 0 )

	, trace([ `buyer contact`, buyer_contact ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT DDI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_ddi , [ 
%=======================================================================

	  buyer_ddi_header_line

	, q(0, 2, line), get_ddi_contact_line

] ).

%=======================================================================
i_line_rule( buyer_ddi_header_line, [ 
%=======================================================================

	q0n(anything)

	, `durchwahl`

	, trace([ `buyer ddi header found` ])

] ).

%=======================================================================
i_line_rule( get_ddi_contact_line, [ 
%=======================================================================

	 or([ 

	 [ q0n(anything), `+`, `49`, buyer_ddi(`0`), append(buyer_ddi(s1), ``,``) ]

	 , [ q0n(anything), `49`, buyer_ddi(`0`), append(buyer_ddi(s1), ``,``) ]

	 , [ q0n(anything), `0049`, buyer_ddi(`0`), append(buyer_ddi(s1), ``,``) ]

	 , [ q0n(anything), `00`, `49`, buyer_ddi(`0`), append(buyer_ddi(s1), ``,``) ]

	, [ q0n(anything), peek_fails([ `telefax` ]), buyer_ddi(s), check(buyer_ddi(start) > 0 ), check(buyer_ddi(end) < 220)] 

	])

	, trace([ `buyer ddi`, buyer_ddi ])

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT FAX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_fax , [ 
%=======================================================================

	  buyer_fax_header_line

	, q(0, 2, line), get_fax_contact_line

] ).

%=======================================================================
i_line_rule( buyer_fax_header_line, [ 
%=======================================================================

	q0n(anything)

	, `telefax`

	, trace([ `buyer fax header found` ])

] ).

%=======================================================================
i_line_rule( get_fax_contact_line, [ 
%=======================================================================

	q0n(anything)

	, or([ 

	 [ q0n(anything), `+`, `49`, buyer_fax(`0`), append(buyer_fax(s1), ``,``) ]

	 , [ q0n(anything), `49`, buyer_fax(`0`), append(buyer_fax(s1), ``,``) ]

	 , [ q0n(anything), `0049`, buyer_fax(`0`), append(buyer_fax(s1), ``,``) ]

	 , [ q0n(anything), `00`, `49`, buyer_fax(`0`), append(buyer_fax(s1), ``,``) ]

	, [ q0n(anything), peek_fails([ `lieferbedingungen` ]), buyer_fax(s), check(buyer_fax(start) > 0 ), check(buyer_fax(y) < -171 ) ] 

	])

	, trace([ `buyer fax`, buyer_fax ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	 total_header_line

	, totals_line

] ).

%=======================================================================
i_line_rule( total_header_line, [
%=======================================================================

	q0n(anything)

	,`Ges`, `.`, `-`, `Brutto`,  newline


] ).


%=======================================================================
i_line_rule( totals_line, [
%=======================================================================

	`eur`, tab, read_ahead( total_net(d) ), total_invoice(d)

	, newline

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_lines, [
%=======================================================================

	q0n(line)	

	, line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ get_line_invoice
		
				, art_line
				
				, art_no_then_descr_line
				
				, descr_item_line
				
				, descr_then_your_number

				, descr_and_item_line

	%, item_then_descr_line

	%, ref_then_descr

	, line ])

		] )

] ).


%=======================================================================
i_line_rule_cut( art_no_then_descr_line, [ 
%=======================================================================

	
	`art`, `.`, `nr`, `.`, line_item(w), q10(tab), line_descr(s1), newline


] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	
	`pos`, `.`, `mat`




] ).


%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	`in`, `allen`, `zuschriften`

] ).

%=======================================================================
i_line_rule_cut( get_line_invoice, [
%=======================================================================
	 
	line_order_line_number(d)

	, trace( [ `line order line number`, line_order_line_number] )	

	, q10( descr(s)), tab

	, line_original_order_date(date), tab

	, trace( [ `line original date`, line_original_order_date ] )	

	, line_quantity(d), line_quantity_uom_code(w), tab

	, trace( [ `line quantity`, line_quantity ] )	

	, line_unit_amount(d), `/`, tab

	, trace( [ `line unit amount`, line_unit_amount ] )

	, line_net_amount(d)

	, trace( [ `line net amount`, line_net_amount ] )

	, newline

		


] ).


%=======================================================================
i_line_rule_cut( descr_item_line, [
%=======================================================================

	 line_descr(s)

	, or([ [`art`, `.`, `nr`, `.`, `:`], [`artikel`, `-`, `nr`, `.`, q01(`:`) ] ]), line_item(w)

	, check(line_descr(font) = 1)

] ).



%=======================================================================
i_rule_cut( descr_and_item_line, [
%=======================================================================

	line_descr_line

	, q01(line)

	, line_item_line

] ).





%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	peek_fails(`__`)	

	, line_descr(s1)

	, check(line_descr(font) = 1)

	, newline

] ).



%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	or( [ `best`, `artikel` ] )

	, `-`, `nr`, `.`	

	, line_item(s)

	, newline

] ).


%=======================================================================
i_rule_cut( item_then_descr_line, [
%=======================================================================

	mfg_item_line

	, line_descr_line

] ).



%=======================================================================
i_line_rule_cut( mfg_item_line, [
%=======================================================================

	`mfr`, `.`, `part`, `nr`, `:`

	, line_item(s)

	, newline

] ).



%=======================================================================
i_rule_cut( descr_then_your_number, [
%=======================================================================

	line_descr_line_2

	, your_number_line

] ).





%=======================================================================
i_line_rule_cut( line_descr_line_2, [
%=======================================================================

	peek_fails(`__`)	

	, line_descr(s1)

] ).



%=======================================================================
i_line_rule_cut( your_number_line, [
%=======================================================================

	`your`, `number`, `:`

	, line_item(s)

	, newline

] ).



%=======================================================================
i_rule_cut( ref_then_descr, [
%=======================================================================

	ref_line

	, line_descr_line

] ).





%=======================================================================
i_line_rule_cut( ref_line, [
%=======================================================================

	`item`, `reference`, `:`

	, line_item(w)

] ).

%=======================================================================
i_line_rule_cut( art_line, [
%=======================================================================

	`art`, `.`, `nr`, `.`, q10( tab )

	, line_item(w), newline

] ).




