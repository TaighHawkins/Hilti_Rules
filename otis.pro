%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - OTIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( otis, `13 February 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_default(new_page).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_page_split_rule_list( [new_invoice_page_section ]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_section( new_invoice_page_section, [ new_invoice_page_line ]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( new_invoice_page_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
     `No`, `de`, `commande`, `:`

     , new_invoice_page
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `FR-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, type_of_supply(`S1`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0900`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, delivery_from_contact( `FROTIS` )
	
	, buyer_dept( `FROTIS` )
	
	, customer_comments( `CORRESPOND A VOTRE REF ARTICLE` )
	
	, suppliers_code_for_buyer( `11740980` )  

	, delivery_note_number( `11740980` )

%	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_order_number_date ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	,[ qn0(line), invoice_total_line]	

	, [ q(0, 10, line), terms_line ]

] ).

%=======================================================================
i_line_rule( terms_line, [ 
%=======================================================================

	`Conditions`,  `Générales`

	, delivery_note_reference(`conditions`)

	, trace([ `terms amd conditions` ])
	
]).

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

	 , delivery_dept_line

	 , q10(delivery_address_line_line)

	 , delivery_street_line

	 , delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`Expéditeur`, `:`, tab, `Destinataire`, `:`,  newline

	, trace([ `delivery header found` ])

]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	delivery_party(s1)

	, check(delivery_party(end) < -10 )

	, trace([ `delivery party`, delivery_party ])
	
]).

%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	delivery_dept(s1)

	, check(delivery_dept(end) < -10 )

	, trace([ `delivery dept`, delivery_dept ])
	
]).

%=======================================================================
i_line_rule( delivery_address_line_line, [ 
%=======================================================================

	delivery_address_line(s1)

	, check(delivery_address_line(end) < -10 )

	, trace([ `delivery address_line`, delivery_address_line])
	
]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	delivery_street(s1)

	, check(delivery_street(end) < -10 )

	, trace([ `delivery street`, delivery_street ])

]).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================
	
	delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s1)

	, trace([ `delivery city`, delivery_city ])

	, check(delivery_city(end) < -10 )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`Assistante`, `:`
	
	, q0n(word)

	, read_ahead( [ append( delivery_from_contact(w), ``, `` ), tab ] )

	, append( buyer_dept(w), ``, `` ), tab

	,`total`

	, trace( [ `delivery from contact`, delivery_from_contact ] ) 

	, trace( [ `buyer dept`, buyer_dept ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number_date, [ 
%=======================================================================

	`No`, `de`, `commande`, `:`, tab

	, order_number(s1), tab

	,`le`

	, invoice_date(date)

	, newline

	, trace( [ `order number`, order_number ] ) 

	, trace( [ `invoice date`, invoice_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	q0n(anything)

	,`total`, `ht`, `cde`, `:`

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
i_line_rule_cut( line_header_line, [ `Ligne`, tab, `Qté`, `Unit`, tab, `Article` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Assistante`, `:`

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_values_line

	, line_descr_line

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	line_order_line_number(d), tab

	, trace([ `line order line number`, line_order_line_number ])

	, line_quantity(d)

	, trace([ `line quantity`, line_quantity ])

	, line_quantity_uom_code(s1), tab

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, read_ahead( [ append( customer_comments(s1), ` `, `` ), tab ] )
	
	, line_item_for_buyer(s1), tab

	, trace([ `line item for buyer`, line_item_for_buyer ])

	, line_original_order_date(date), tab

	, trace([ `line original order date`, line_original_order_date ])

	, dummy(s1)

	, newline

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	q10([dummy(s1), tab])

	, dummy(s), tab

	, line_descr(s1), tab

	, trace([ `line description`, line_descr ])

	, line_unit_amount_x(d), tab

	, line_net_amount(d)

	, trace( [ `line net amount`, line_net_amount ] )

	, newline

] ).

i_op_param( orders05_idocs_first_and_last_name( buyer_dept, _, NAME1 ), _, _, _, _) :- result( _, invoice, buyer_dept, NU ), string_to_upper(NU, NAME1).

i_op_param( orders05_idocs_first_and_last_name( delivery_from_contact, _, NAME2 ), _, _, _, _) :- result( _, invoice, delivery_from_contact, NU2 ), string_to_upper(NU2, NAME2).
