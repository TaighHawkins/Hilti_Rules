%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FRIGOVENETA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( frigoveneta, `10 December 2014` ).

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

	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10658906` ) ]	%TEST
		, suppliers_code_for_buyer( `13031529` )	% PROD
	] ) 

%	, customer_comments( `Customer Comments` )
%	, or( [ [ q0n(line), customer_comments_line ] , customer_comments( `` ) ])

%	, shipping_instructions( `Shipping Instructions` )
%	, shipping_instructions( `` )

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_order_number ]

	,[q0n(line),  get_order_date ]

	,[q0n(line), get_buyer_contact ]

	, get_invoice_lines

	, or( [ [ q0n(line), get_net_total_number], total_net( `0` ) ] )

	, or( [ [ q0n(line), get_invoice_total_number], total_invoice( `0` ) ] )
	
	
	,[ q0n(line), get_delivery_party ]

	, buyer_ddi(`0442659030`)

	, buyer_email(`frigoveneta@frigoveneta.it`)

	, replicate_address

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

	, or( [ `DDeell`, `Del` ] ), tab
	
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

	or( [ [ `OOrrddiinnee`, `nn`, q10( [ `°°` ] ) ]
	
		, [ `Ordine`, `n`, `°` ]
		
	] )

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

	`Totale`, `Importo`, `Ordine`, q10( `€` ), q10( tab )

	, total_net(d)

	, newline

	, trace( [ `total net`, total_net ] )

] ).

%=======================================================================
i_line_rule( get_invoice_total_number, [
%=======================================================================

	`Totale`, `Importo`, `Ordine`, q10( `€` ), q10( tab )

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

	, generic_item( [ line_item_for_buyer, s1, tab ] )

	, or( [ [ or([ [line_item(w), `/`, num(w)], line_item(w) ]),  tab

			, trace([`line item`, line_item])
			
		]
		
		, line_item( `Missing` )
		
	] )

	, generic_item( [ line_descr, s1, tab ] )

	, generic_item( [ line_quantity_uom_code, w, tab ] )

	, generic_item( [ line_quantity,d, tab ] )

	, q10( generic_item( [ line_unit_amount, d ] ) )

	, generic_item( [ line_original_order_date, date, newline ] )


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


%=======================================================================
i_rule( replicate_address, [
%=======================================================================

	q10([ with(invoice, buyer_contact, BC), delivery_contact(BC) ])

	, q10([ with(invoice, buyer_email, BE), delivery_email(BE) ])

	, q10([ with(invoice, buyer_ddi, BI), delivery_ddi(BI) ])

	, q10([ with(invoice, buyer_fax, BF), delivery_ddi(BF) ])


] ).



