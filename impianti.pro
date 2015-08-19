%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - AB IMPIANTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ab_impianti, `18 June 2013` ).

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

	, [ or([ 
   	
	[ test(test_flag), get_suppliers_code_for_buyer_test ]    %TEST
    	
	 ,get_suppliers_code_for_buyer_prod  %PROD

 	]) ]

%	, customer_comments( `Customer Comments` )
%	, or( [ [ q0n(line), customer_comments_line ] , customer_comments( `` ) ])

%	, shipping_instructions( `Shipping Instructions` )
%	, shipping_instructions( `` )

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	,[q0n(line), get_invoice_totals ]

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	delivery_party_line

	, delivery_address_line_two
	
] ).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	`Luogo`, `di`, `destinazione`, `:`, tab

	, delivery_party(s1), newline

	, trace([ `delivery party`, delivery_party ])
	
] ).

%=======================================================================
i_line_rule( delivery_address_line_two, [ 
%=======================================================================

	delivery_street(s), `-`

	, trace([ `delivery street`, delivery_street ])

	, delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s)

	, `(`, delivery_state(w), `)`, newline

	, trace([ `delivery state`, delivery_state ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	 `Ordine`, `fornitore`, `nr`, `.`

	, order_number(s)

	, trace( [ `order number`, order_number ] ) 

	, `del`

	, invoice_date(date)

	, newline

	, trace( [ `order date`, invoice_date] ) 

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

	, `contatto`, `:`, tab

	, read_ahead(buyer_contact(s1)), delivery_contact(s1), newline

	, trace([ `buyer contact`, buyer_contact ])

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(anything)

	, `tel`, `:`

	, read_ahead([ buyer_ddi(s), `fax`, `:`]), delivery_ddi(s)

	, `fax`, `:`	

	, trace([ `buyer ddi`, buyer_ddi ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIERS CODE FOR BUYER	TEST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_suppliers_code_for_buyer_test, [
%=======================================================================

	or([ [`DIVISIONE`, `MECCANICA`, suppliers_code_for_buyer(`10658906`) ]

	, [`DIVISIONE`, `ELETTRICA`, suppliers_code_for_buyer(`10656131`) ] ])

	, trace( [ `total invoice`, total_invoice ] )	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIERS CODE FOR BUYER	PROD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_suppliers_code_for_buyer_prod, [
%=======================================================================

	or([ [`DIVISIONE`, `MECCANICA`, suppliers_code_for_buyer(`13011431`) ] 

	, [`DIVISIONE`, `ELETTRICA`, suppliers_code_for_buyer(`17586413`) ] ])

	, trace( [ `total invoice`, total_invoice ] )	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_totals, [
%=======================================================================

	q0n(anything)

	,`Totale`, `ordine`, `(`, `IVA`, `esclusa`, `)`, `EUR`, `:`

	, read_ahead(total_net(d))

	, total_invoice(d)

	, newline

	, trace( [ `total invoice`, total_invoice ] )	

] ).

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

		, or([  line_invoice_line, line_invoice_line_two, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Cod`, `.`, `articolo`, tab, `Descrizione`, tab, `UM` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	`CONDIZIONI`, `GENERALI`, `DI`, `FORNITURA`,  newline

] ).

%=======================================================================
i_rule_cut( line_invoice_line, [ 
%=======================================================================

	line_values_line

	, or([ [ q(0, 2, line) , line_item_line ], line_item(`missing`) ])

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	line_item_for_buyer(s1), tab

	, trace([`line item for buyer`, line_item_for_buyer])

	, line_descr(s1), tab

	, trace([`line description`, line_descr])

	, line_quantity_uom_code(w), tab

	, trace([`line quantity uom code`, line_quantity_uom_code])

	, line_quantity(d), tab

	, trace([`line quantity`, line_quantity])

	, costo(d), tab

	, q10([ sconti(d), tab ])

	, line_net_amount(d), tab

	, trace([`line net`, line_net_amount])

	, line_original_order_date(date)

	, trace([`line original order date`, line_original_order_date])

	, newline

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)


] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	`Vs`, `.`, `cod`, `.`, `:`

	, line_item(w1)

	, trace([`line item`, line_item])

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_two, [
%=======================================================================

	line_item_for_buyer(s1), tab

	, trace([`line item for buyer`, line_item_for_buyer])

	, line_descr(s1), tab

	, trace([`line description`, line_descr])

	, line_quantity_uom_code(w), tab

	, trace([`line quantity uom code`, line_quantity_uom_code])

	, line_quantity(d), tab

	, trace([`line quantity`, line_quantity])

	, costo(d), tab

	, q10([ sconti(d), tab ])

	, line_net_amount(d), tab

	, trace([`line net`, line_net_amount])

	, line_original_order_date(date)

	, trace([`line original order date`, line_original_order_date])

	, newline

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)


] ).