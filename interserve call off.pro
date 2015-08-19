%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - INTERSERVE CALL OFF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( interserve_call_off, `09 May 2013` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	buyer_party( `LS` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `GB-INTERSV` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, get_suppliers_code_for_buyer
	, get_delivery_note_number

%	, suppliers_code_for_buyer( `12224307` ) % prod
%	, suppliers_code_for_buyer( `10585780` ) % test

%	, customer_comments( `Customer Comments` )
	, [ q0n(line), customer_comments_line ]

%	, shipping_instructions( `Shipping Instructions` )
	, [ q0n(line), shipping_instructions_line ]

%	,[q0n(line), get_delivery_details ]

%	,[q0n(line), get_delivery_first_line ]

%	,[q0n(line), get_delivery_location ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_email ]

	,[ q0n(line), get_general_original_order_date]

	, check( i_user_check( gen_cntr_set, 20, 1 ) )
	, get_invoice_lines

	, total_net(`0`), total_invoice(`0`)

%	,[ q0n(line), get_invoice_total_number]


] ).


%=======================================================================
i_rule( get_suppliers_code_for_buyer, [ 
%=======================================================================

	q0n(line)

	, suppliers_code_for_buyer_header_line

	, suppliers_code_for_buyer_line

	, trace([ `suppliers code for buyer`, suppliers_code_for_buyer ])

] ).


%=======================================================================
i_line_rule( suppliers_code_for_buyer_header_line, [ `sold`, `-`, `to` ]).
%=======================================================================

%=======================================================================
i_line_rule( suppliers_code_for_buyer_line, [ suppliers_code_for_buyer(w) ]).
%=======================================================================


%=======================================================================
i_rule( get_delivery_note_number, [ 
%=======================================================================

	q0n(line)

	, delivery_note_number_header_line

	, delivery_note_number_line

	, trace([ `delivery note number`, delivery_note_number ])

] ).

%=======================================================================
i_line_rule( delivery_note_number_header_line, [ `ship`, `-`, `to` ]).
%=======================================================================

%=======================================================================
i_line_rule( delivery_note_number_line, [ delivery_note_number(w) ]).
%=======================================================================



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERAL ORIGINAL ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_general_original_order_date, [ 
%=======================================================================

	q0n(anything)

	, `date`, `:`, q10(tab)

	, due_date(date)

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
 
	q0n(anything)

	, `cost`, `centre`, `:`, tab

	, customer_comments(s1), tab, `delivery`, `date`

	, trace([ `customer comments`, customer_comments ])


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( shipping_instructions_line, [
%=======================================================================
 
	q0n(anything)

	, `cost`, `centre`, `:`, tab

	, shipping_instructions(s1), tab, `delivery`, `date`

	, trace([ `shipping instructions`, shipping_instructions ])


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delivery ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_delivery_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	gen1_address_details_without_names( [ delivery_left_margin, delivery_start_line,
					delivery_street, delivery_address_line, delivery_city, delivery_state, delivery_postcode,
					delivery_end_line ] )


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( delivery_start_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	`ship`, `-`, `to`, `:`, tab

	, check( i_user_check( gen1_store_address_margin( delivery_left_margin ), -348, 10, 10 ) )
	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( get_delivery_first_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 `sold`, `-`, `to`, `:`, tab

	, read_ahead(delivery_dept(s1)), delivery_party(s1)

	, trace([ `delivery party`, delivery_party ])



] ).


%=======================================================================
i_line_rule( delivery_end_line, [ 
%=======================================================================

	or( [with(delivery_postcode)

	, [`please`, `enter`, `quantity` ] ])


] ).

%=======================================================================
i_line_rule( get_delivery_location, [
%=======================================================================
 
	q0n(anything)

	, `cost`, `centre`, `:`, tab

	, delivery_location(w), `/`, location(w)

	, trace([ `delivery location`, delivery_location ])

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

	,`date`, `:`

	, invoice_date(date)

	, newline

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

	 `order`, `no`, `:`

	, order_number(s1), tab, `cost`, `centre`

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

	`contacts`, `:`

	, buyer_contact(s1)

	, trace([ `buyer contact`, buyer_contact ])


] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	get_buyer_ddi_header

	, get_buyer_ddi_line


] ).

%=======================================================================
i_line_rule( get_buyer_ddi_header, [ 
%=======================================================================

	`contacts`, `:`

	, trace([ `buyer ddi`, buyer_ddi ])


] ).

%=======================================================================
i_line_rule( get_buyer_ddi_line, [ 
%=======================================================================

	buyer_ddi(w), append(buyer_ddi(w), ``, ``)

	, trace([ `buyer ddi`, buyer_ddi ])


] ).

%=======================================================================
i_line_rule( get_buyer_email,[
%=======================================================================

	`contacts`, `:`

	, names(w), names(w), tab

	, buyer_email(s1)

	, trace([ `buyer fax`, buyer_fax ])


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_total_number, [
%=======================================================================

	`total`, `:`, tab		

	, read_ahead(total_invoice(d))

	, total_net(d)

	, newline

	, trace( [ `total invoice`, total_invoice ] )	

	, trace( [ `total net`, total_net ] )	

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

		, or([ get_line_invoice, line ])

		] )

		, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	q0n(anything)

	, `M`, `Required`, tab, `multiples`, `of`, `:`,  newline

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or([ [q0n(anything), `freight`, tab],  [`please`, `enter`, `quantity`, `required`] ])

] ).

%=======================================================================
i_line_rule_cut( get_line_invoice, [
%=======================================================================
	 
	q0n(anything)

	, line_quantity_uom_code(w), tab

	, check(line_quantity_uom_code(start) > -85 )

	, trace( [ `line quantity uom code`, line_quantity_uom_code ] )

	, peek_fails(`0`), line_quantity(d), tab, line_item(d), tab

	, check(line_item(start) > 20)

	, trace( [ `line item`, line_item ] )

	, line_descr(s1), tab

	, trace( [ `line descr`, line_descr ] )	

	, pieces(s1)

	, trace( [ `line pieces found` ] )	

	, q10([ with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, trace( [ `original order date set to`, line_original_order_date ] ) ])

	, newline

	, check( i_user_check( gen_cntr_inc_str, 20, LINE_NUMBER ) )

	, line_order_line_number(LINE_NUMBER)

		
] ).

