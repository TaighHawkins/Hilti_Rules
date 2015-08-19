%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FRIGOVENETA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( frigoveneta, `13 February 2013` ).

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

%	, suppliers_code_for_buyer( `13031529` )   % PROD
	, suppliers_code_for_buyer( `10658906` )   %TEST

%	, customer_comments( `Customer Comments` )
%	, or( [ [ q0n(line), customer_comments_line ] , customer_comments( `` ) ])

%	, shipping_instructions( `Shipping Instructions` )
%	, shipping_instructions( `` )

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_order_number ]

	,[q0n(line),  get_order_date ]

	,[q0n(line), get_buyer_contact ]

	, get_invoice_lines

	,[ q0n(line), get_net_total_number]

	,[ q0n(line), get_invoice_total_number]
	
	
	,[ q0n(line), get_delivery_party ]

	, buyer_ddi(`0442659030`)

	, buyer_email(`frigoveneta@frigoveneta.it`)

	, replicate_address



] ).

%=======================================================================
i_rule( replicate_address, [
%=======================================================================

	q10([ with(invoice, buyer_contact, BC), delivery_contact(BC) ])

	, q10([ with(invoice, buyer_email, BE), delivery_email(BE) ])

	, q10([ with(invoice, buyer_ddi, BI), delivery_ddi(BI) ])

	, q10([ with(invoice, buyer_fax, BF), delivery_ddi(BF) ])


] ).





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_party, [
%=======================================================================
 
	 `CANTIERE`, `:`

	, dateref(s), tab

	, delivery_party(s)

	, trace([ `delivery party`, delivery_party ])

	, check(delivery_party(start) > -145 )

	, check(delivery_party(end) < 110 )

	, newline 

	 
] ).


%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  

	 delivery_header_line

	 , q(0,2,line)

	 , delivery_address_line

]).
 	
%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	
	`Emesso`, `Da`, `:`

	, trace([ `delivery header found` ])
	

]).

%=======================================================================
i_line_rule( delivery_address_line, [ 
%=======================================================================

	
	delivery_party(s)

	, trace([ `delivery party`, delivery_party ]) 

	,`-`, `-`, `-`

	, delivery_street(s)

	, trace([ `delivery party`, delivery_party ]) 

	,`-`, `-`, `-`

	, delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ]) 
	
	, delivery_city(s)

	, trace([ `delivery city`, delivery_city ]) 

	,`-`, `-`

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

	,`DDeell`, tab
	
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

	`OOrrddiinnee`, `nn`

	, order_number(s)

	, trace( [ `order number`, order_number ] ) 

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

	, `Emesso`, `Da`, `:`

	, buyer_contact(s)

	, newline

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_net_total_number, [
%=======================================================================

	 

	`Totale`, `Importo`, `Ordine`, tab

	, total_net(d)

	, newline

	, trace( [ `total net`, total_net ] )

] ).

%=======================================================================
i_line_rule( get_invoice_total_number, [
%=======================================================================

	`Totale`, `Importo`, `Ordine`, tab

	, total_invoice(d)

	, newline

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
i_line_rule_cut( line_header_line, [ `Ns`, `.`, `Cod`, `.`, `Art`, `.`, tab, `Cod` ] ).
%=======================================================================


%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================


	`Totale`, `Importo`, `Ordine`, tab

	] ).

%=======================================================================
i_line_rule_cut( get_invoice_line, [
%=======================================================================

	line_no(d)

	, line_item_for_buyer(s), tab

	, trace([`customer line item`, customer_line_item])

	, or([ [line_item(w), `/`, num(w)], line_item(w) ]),  tab

	, trace([`line item`, line_item])

	, line_descr(s), tab

	, trace([`line descr`, line_descr])

	, line_quantity_uom_code(w)

	, tab

	, line_quantity(d), tab

	, trace([`line quantity`, line_quantity])

	, line_unit_amount(d)

	, trace([`line net amount`, line_net_amount])

	, line_original_order_date(date)

	, newline


] ).


%=======================================================================
i_rule_cut( decode_line_uom_code, [
%=======================================================================

	or([ [ `pz`, line_quantity_uom_code( `EA` ) ]

		, [ `cf`, line_quantity_uom_code( `EA` ) ]

		, [ `m`, line_quantity_uom_code( `M` ) ]

		, [ `mt`, line_quantity_uom_code( `M` ) ]

		, [ `ml`, line_quantity_uom_code( `M` ) ]

		, [ word ]

	])

] ).

