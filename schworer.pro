%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - SHWORER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( schworer, `24 July 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `DE-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

%	, type_of_supply(`S0`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	,or([ [ test(test_flag), suppliers_code_for_buyer( `10279196` ) ]   %TEST
	    , suppliers_code_for_buyer( `10279196` ) ])                  %PROD  

	,[q0n(line), get_delivery_address]

	,[q0n(line), get_buyer_contact]

	,[q0n(line), get_buyer_fax]

	,[q0n(line), get_buyer_email]

	,[q0n(line), get_delivery_contact]

	,[q0n(line), get_delivery_fax]

	,[q0n(line), get_delivery_email]

	,[q0n(line), get_order_number]

	,[q0n(line), get_order_date]

	,[q0n(line), get_due_date]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	,[q0n(line), invoice_total_line ]
	
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

	, delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`Bitte`, `liefern`, `Sie`, `an`, `:`,  newline
	
]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	delivery_party(s1)

	, newline

	, trace([ `delivery party`, delivery_party ])
	
]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	delivery_street(s1)

	, trace([ `delivery street`, delivery_street ])

	, newline

]).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================

	delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s1)

	, trace([ `delivery city`, delivery_city ])

	, newline

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	buyer_contact_header

	, buyer_contact_line

] ).

%=======================================================================
i_line_rule( buyer_contact_header, [ 
%=======================================================================

	`AnsprechpartnerIn`, tab, `Telefon`,  newline

] ).

%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	buyer_contact(s1), tab

	, trace( [ `buyer contact`, buyer_contact ] ) 

	, buyer_ddi(sf), `/`

	, append(buyer_ddi(sf), ``, ``), `-`

	, append(buyer_ddi(s1), ``, ``)

	, newline

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_fax, [ 
%=======================================================================

	q0n(anything)

	,`fax`, `:`, tab

	, buyer_fax(sf), `/`

	, append(buyer_fax(sf), ``, ``), `-`

	, append(buyer_fax(sf), ``, ``), `-`

	, append(buyer_fax(s), ``, ``), `-`

	, newline

	, trace( [ `buyer fax`, buyer_fax ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	q0n(anything)

	,`mail`, `:`

	, buyer_email(s1)

	, newline

	, trace( [ `buyer email`, buyer_email ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	delivery_contact_header

	, delivery_contact_line

] ).

%=======================================================================
i_line_rule( delivery_contact_header, [ 
%=======================================================================

	`AnsprechpartnerIn`, tab, `Telefon`,  newline

] ).

%=======================================================================
i_line_rule( delivery_contact_line, [ 
%=======================================================================

	delivery_contact(s1), tab

	, trace( [ `delivery contact`, delivery_contact ] ) 

	, delivery_ddi(sf), `/`

	, append(delivery_ddi(sf), ``, ``), `-`

	, append(delivery_ddi(s1), ``, ``)

	, newline

	, trace( [ `delivery ddi`, delivery_ddi ] ) 

] ).

%=======================================================================
i_line_rule( get_delivery_fax, [ 
%=======================================================================

	q0n(anything)

	,`fax`, `:`, tab

	, delivery_fax(sf), `/`

	, append(delivery_fax(sf), ``, ``), `-`

	, append(delivery_fax(sf), ``, ``), `-`

	, append(delivery_fax(s), ``, ``), `-`

	, newline

	, trace( [ `delivery fax`, delivery_fax ] ) 

] ).

%=======================================================================
i_line_rule( get_delivery_email, [ 
%=======================================================================

	q0n(anything)

	,`mail`, `:`

	, delivery_email(s1)

	, newline

	, trace( [ `delivery email`, delivery_email ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	`bestnr`, `.`

	, order_number(s1)

	, newline

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================

	`vom`

	, invoice_date(date)

	, newline

	, trace( [ `invoice date`, invoice_date ] ) 

] ).

%=======================================================================
i_line_rule( get_due_date, [ 
%=======================================================================

	q0n(anything)

	,`liefertermin`, `:`, tab

	, due_date(date)

	, newline

	, trace( [ `due date`, due_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	`Gesamtnettowert`, `ohne`, `Mwst`, `EUR`, tab

	, read_ahead(total_invoice(d))

	, total_net(d)

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ line_invoice_rule, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, tab, `Material`, tab, `Bezeichnung` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Gesamtnettowert`, `ohne`, `Mwst`, `EUR`, tab ]
	
		, [ word, `Kommanditgesellschaft`, `,`, `Firmensitz` ]
		
	] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_values_line

	, q10(line_due_date_line)

	, or( [ [ q(0, 3, line)

			, line_item_line
			
		]
		
		, [ line_item( `Missing` ) ]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	line_order_line_number(d), q01(tab)

	, trace([ `line order line number`, line_order_line_number ])

	, q10([line_item_for_buyer(s1), tab

	, trace([ `line item for buyer`, line_item_for_buyer ]) ])

	, line_descr(s1), tab

	, trace([ `line description`, line_descr ])

	, line_quantity(d)

	, trace([ `line quantity`, line_quantity ])

	, line_quantity_uom_code(w), tab

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, einzelpreis(s1), tab

	, line_net_amount(d)

	, trace( [ `line net amount`, line_net_amount ] )

	, q10([ with( invoice, due_date, DATE )

	, line_original_order_date( DATE ) ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( line_due_date_line, [
%=======================================================================

	`Liefertermin`, `:`

	, line_original_order_date(date)

	, newline

	, trace( [ `line original order date`, line_original_order_date ] ) 

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	or([ [`ihre`, `materialnummer`], [`art`, `.`, `nr`, `.`] ])

	, line_item(s1)

	, trace([ `line item`, line_item ])

	, newline

] ).