%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - ATZWANGER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( atzwanger_test, `27 November 2013` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `IT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

%	, suppliers_code_for_buyer( `13006356` )   %PROD
	, suppliers_code_for_buyer( `10658906` )   %TEST

	, customer_comments( `` )
	, shipping_instructions( `` )

	, [ q0n(line), customer_comments_line ]

	, [ q0n(line), shipping_instructions_line ]

	,[q0n(line), get_delivery_address ]

	, delivery_address_2

	,[q0n(line), get_order_number ]

	,[q0n(line),  get_order_date ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_delivery_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_delivery_ddi ]

	, get_invoice_lines

	,[ q0n(line), get_invoice_total_number]
	
	, [ q0n(line), get_default_vat_rate ]
	


] ).


%=======================================================================
i_line_rule( get_default_vat_rate, [ 
%=======================================================================

	q0n(anything)

	, `CODICE`, `IVA`, `:`

	, q0n(anything)

	, default_vat_rate(d), `%`
	
	, trace( [ `default vat rate`, default_vat_rate ] )

]).

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	q0n(anything)

	, `nr`, `.`, `cig`, `:`

	, customer_comments(`CIG: `)

	, tab

	, append(customer_comments(s), ``, ``)

	, newline


]).

%=======================================================================
i_line_rule( shipping_instructions_line, [ 
%=======================================================================

	q0n(anything)

	, `nr`, `.`, `cig`, `:`

	, shipping_instructions(`CIG: `)

	, tab

	, append(shipping_instructions(s), ``, ``)

	, newline


]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( delivery_address_2, [
%=======================================================================
 
	without(delivery_party)

	, delivery_note_number(`20258370`)  

	
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

	 , delivery_street_line

	 , delivery_city

	 , delivery_postcode

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	q0n(anything)

	, `Destinazione`, `merce`,  newline

	, trace([ `delivery header found` ])
	

]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================
	
	q0n(anything)

	, delivery_party(s)

	, check(delivery_party(start) > -70 )

	, trace([ `delivery party`, delivery_party ])

	, newline
	

]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	q0n(anything)

	, delivery_street(s)

	, check(delivery_street(start) > -70 )

	, trace([ `delivery street`, delivery_street ])

	, newline
	

]).

%=======================================================================
i_line_rule( delivery_city, [ 
%=======================================================================
	

	q0n(anything)

	, delivery_city(s)

	, check(delivery_city(start) > -70 )

	, trace([ `delivery city`, delivery_city ])

	, newline
	

]).

%=======================================================================
i_line_rule( delivery_postcode, [ 
%=======================================================================

	q0n(anything)

	, delivery_postcode(d)

	, check(delivery_postcode(start) > -70 )

	, trace([ `delivery postcode`, delivery_postcode ])

	, tab

	, delivery_state(w)

	, trace([ `delivery state`, delivery_state ])

	, newline
	

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================

	q0n(anything)

	, `Data`, `ordine`, tab, `:`
	
	, invoice_date(date)

	, trace( [ `invoice date`, invoice_date] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything)

	,`Ordine`, `acquisto`, `Nr`, `:`, tab

	, order_number(s)

	, trace( [ `order number`, order_number ] ) 

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

	q0n(anything)

	,`Ns`, `.`, `Rif`, `.`, tab, `:`

	, read_ahead([ dummy(w), delivery_contact(w) ]), append(delivery_contact(w), ` `, ``)

	, trace([ `delivery contact`, delivery_contact ])

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(anything)

	,`Ns`, `.`, `Rif`, `.`, tab, `:`

	, read_ahead([ dummy(w), buyer_contact(w) ]), append(buyer_contact(w), ` `, ``)

	, trace([ `buyer contact`, buyer_contact ])

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(anything)

	,`Telefono`, tab, `:`

	, buyer_ddi(w), `/`, append(buyer_ddi(w), ``, ``)

	, trace([ `buyer ddi`, buyer_ddi ])

] ).


%=======================================================================
i_line_rule( get_delivery_ddi, [ 
%=======================================================================

	q0n(anything)

	,`Telefono`, tab, `:`

	, delivery_ddi(w), `/`, append(delivery_ddi(w), ``, ``)

	, trace([ `delivery ddi`, delivery_ddi ])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_total_number, [
%=======================================================================

	q0n(anything)

	,`importo`, `netto`, `:`, tab, total_net(d)

	,`Totale`, `:`, tab

	, total_invoice(d)

	, `eur`

	, newline

	, trace( [ `total invoice`, total_invoice ] )	

	, trace( [ `total net`, total_net ] )	

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
i_line_rule_cut( line_header_line, [ `Pos`, `.`, `Articolo`, tab, `Quantità`, tab, `Prezzo` ] ).
%=======================================================================


%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or([ [ `-`, `-`, `-`, `-`, `-`, `-`, `-`, `-`, `-`, `-`, `-`, `-`, tab, `PREGO`, `RITORNARCI` ]

		, [ `Pos`, `.`, `Articolo`, tab, `Quantità`, tab, `Prezzo` ] 

	])

] ).

%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	get_line_quantity_line

	, get_line_descr_line

	, get_line_item_line

] ).

%=======================================================================
i_line_rule_cut( get_line_quantity_line, [
%=======================================================================

	q0n(anything)

	, line_quantity(d), tab

	, check(line_quantity(start) > -260 )

	, trace([ `line quantity`, line_quantity ])

	, or([ [`pz`, line_quantity_uom_code(`EA`)], [`m`, line_quantity_uom_code(`M`)] ])

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, q0n(anything)

	, line_unit_amount(d), `EUR`

	, trace([ `line net amount`, line_net_amount ])

	, q0n(anything)

	, line_original_order_date(date)

	, trace([ `line orginal order date`, line_original_order_date ])

	, newline
	

] ).

%=======================================================================
i_line_rule_cut( get_line_descr_line, [
%=======================================================================

	line_descr(s)

	, trace([ `line descr`, line_descr ])

] ).

%=======================================================================
i_line_rule_cut( get_line_item_line, [
%=======================================================================

	  or( [ [ `Vs`, `codice`, `numero`, tab ]
	  
			, [ `Art`, `.` ]
			
		] )

	, line_item(s)

	, trace([ `line item`, line_item ])

	, newline

	


] ).

