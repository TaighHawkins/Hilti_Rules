%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - PROPAK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( propak, `01 July 2013` ).

i_date_format( 'm/d/y' ).

i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `CA-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`6800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11235581` ) ]    %TEST
	    , suppliers_code_for_buyer( `10683389` )                      %PROD
	]) ]


	, shipping_comments( `` )
	, shipping_instructions( `` )

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_fax ]

	,[q0n(line), get_buyer_email ]

	,[q0n(line), get_delivery_contact ]

	,[q0n(line), get_delivery_ddi ]

	,[q0n(line), get_delivery_fax ]

	,[q0n(line), get_delivery_email ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

	, get_invoice_lines

	,[ qn0(line), invoice_total_line]
	

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

	 , delivery_street_line

	 , delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	q0n(anything)

	,`ship`, `to`, `:`

	, delivery_party(`PROPAK SYSTEMS LTD`)

	, trace([ `delivery party`, delivery_party ])
	
]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	q0n(anything)

	, delivery_street(s1)

	, check(delivery_street(start) > 0 )

	, trace([ `delivery street`, delivery_street ])

	, newline
	
]).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================
	
	q0n(anything)

	, delivery_city(s), `,`

	, trace([ `delivery city`, delivery_city ])

	, delivery_state(w)

	, trace([ `delivery state`, delivery_state ])

	, delivery_postcode(s)

	, check(delivery_postcode(start) > 0 )

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

	get_buyer_contact_header

	, get_buyer_contact_line

] ).

%=======================================================================
i_line_rule( get_buyer_contact_header, [ 
%=======================================================================

	`SALES`, `ORDER`, `#`, tab, `ACCOUNT`

	, trace( [ `buyer contact header found` ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_contact_line, [ 
%=======================================================================

	q0n(anything)

	, or([ [`sfields`, buyer_contact(`Sandra Fields`)], [`cshanaha`, buyer_contact(`Curtis Shanahan`)] ])

	, newline

	, trace( [ `buyer contact`, buyer_contact] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	`Bus`, `:`, `(`

	, buyer_ddi(w), `)`

	, append(buyer_ddi(`-`), ``, ``)

	, append(buyer_ddi(s), ``, ``)

	,`Fax`, `:`

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_fax, [ 
%=======================================================================

	q0n(anything)

	,`Fax`, `:`, `(`

	, buyer_fax(w), `)`

	, append(buyer_fax(`-`), ``, ``)

	, append(buyer_fax(s), ``, ``)

	,`email`, `:`

	, trace( [ `buyer fax`, buyer_fax ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

  buyer_email(FROM)
 , trace([ `buyer email`, buyer_email ])

] )

:-
 i_mail( from, FROM )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	get_delivery_contact_header

	, get_delivery_contact_line

] ).

%=======================================================================
i_line_rule( get_delivery_contact_header, [ 
%=======================================================================

	`SALES`, `ORDER`, `#`, tab, `ACCOUNT`

	, trace( [ `delivery contact header found` ] ) 

] ).

%=======================================================================
i_line_rule( get_delivery_contact_line, [ 
%=======================================================================

	q0n(anything)

	, or([ [`sfields`, delivery_contact(`SANDRA FIELDS`)], [`cshanaha`, delivery_contact(`CURTIS SHANAHAN`)] ])

	, newline

	, trace( [ `delivery contact`, delivery_contact] ) 

] ).

%=======================================================================
i_line_rule( get_delivery_ddi, [ 
%=======================================================================

	`Bus`, `:`, `(`

	, delivery_ddi(w), `)`

	, append(delivery_ddi(`-`), ``, ``)

	, append(delivery_ddi(s), ``, ``)

	,`Fax`, `:`

	, trace( [ `delivery ddi`, delivery_ddi ] ) 

] ).

%=======================================================================
i_line_rule( get_delivery_fax, [ 
%=======================================================================

	q0n(anything)

	,`Fax`, `:`, `(`

	, delivery_fax(w), `)`

	, append(fax_ddi(`-`), ``, ``)

	, append(delivery_fax(s), ``, ``)

	,`email`, `:`

	, trace( [ `delivery fax`, delivery_fax ] ) 

] ).

%=======================================================================
i_line_rule( get_delivery_email, [ 
%=======================================================================

  delivery_email(FROM)
 , trace([ `delivery email`, delivery_email ])

] )

:-
 i_mail( from, FROM )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	get_order_number_header

	, get_order_number_line

] ).

%=======================================================================
i_line_rule( get_order_number_header, [ 
%=======================================================================

	`purchase`, `order`, `number`

	, trace( [ `order number`, order_number ] ) 

] ).

%=======================================================================
i_line_rule( get_order_number_line, [ 
%=======================================================================

	q0n(anything)

	, order_number(s1)

	, tab, num(d), newline

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	get_invoice_date_line

	, get_invoice_date_footer

] ).

%=======================================================================
i_line_rule( get_invoice_date_line, [ 
%=======================================================================

	invoice_date(date)

	, newline

	, trace( [ `order date`, invoice_date ] ) 

] ).

%=======================================================================
i_line_rule( get_invoice_date_footer, [ 
%=======================================================================

	`PURCHASE`, tab, `ORDER`, `DATE`, `:`

	, trace( [ `order date footer found` ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	`subtotal`, `:`, tab, `$`

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

		, or([ line_invoice_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 	`#`, tab, `qty`, tab, `tag`, tab, `arrive` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`subtotal`, `:`, tab, `$`

] ).

%=======================================================================
i_rule_cut( line_invoice_line, [
%=======================================================================

	read_ahead(line_values_line)

	, read_ahead(find_item_code)

	, line

	, q(2,0,[peek_fails(our_part_line), line_descr_line ])

] ).


%=======================================================================
i_rule_cut( find_item_code, [
%=======================================================================

	or([  [ q(0,2,line), hilti_code_line ]

		, [ end_code_line ]

		, [ q(0,2,line), peek_fails(our_part_line), number_code_line ]

		, [ q(1,2,line), number_start_line ]

		, line_item(`Missing`) ])

] ).

%=======================================================================
i_line_rule_cut( number_start_line, [
%=======================================================================

	 line_item( f( [ begin, q([ dec],4,7), end ]) )

	, check(line_item(start) > -175 )
	, check(line_item(end) < 187 )


] ).

%=======================================================================
i_line_rule_cut( hilti_code_line, [
%=======================================================================

	q0n(anything)

 	, `hilti`, line_item( f( [ begin, q([ dec],4,7), end ]) )

	, check(line_item(start) > -175 )
	, check(line_item(end) < 187 )


] ).

%=======================================================================
i_line_rule_cut( end_code_line, [
%=======================================================================

	q0n(anything)

 	, line_item( f( [ begin, q([ dec],4,7), end ]) )

	, tab, word, tab

	, check(line_item(start) > -175 )
	, check(line_item(end) < 187 )

	
] ).


%=======================================================================
i_line_rule_cut( number_code_line, [
%=======================================================================

	q0n(anything)

	, `#`

 	, line_item( f( [ begin, q([ dec],4,7), end ]) )

	, check(line_item(start) > -175 )
	, check(line_item(end) < 187 )

	
] ).

%=======================================================================
i_line_rule_cut( our_part_line, [
%=======================================================================

	`our`, `part`, `#`

	
] ).



%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	 line_order_line_number(d), tab

	, trace([ `line order line number`, line_order_line_number ])

	, line_quantity(d), tab

	, trace([ `line quantity`, line_quantity ])

	, orderdate(date)

	, q01(tab)

	, line_descr(s1)

	, trace([ `line description`, line_descr ])

	, q0n(anything)

	, `$`, line_net_amount(d)

	, trace([ `line net amount`, line_net_amount ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	append(line_descr(s1), ` `, ``), newline

	, trace([ `line description`, line_descr ])
	

] ).


i_op_param( orders05_idocs_first_and_last_name( buyer_contact, NAME1, `PROPAK SYSTEMS LTD` ), _, _, _, _) :- result( _, invoice, buyer_contact, NU ), string_to_upper(NU, NAME1).

i_op_param( orders05_idocs_first_and_last_name( delivery_contact, NAME1, `PROPAK SYSTEMS LTD` ), _, _, _, _) :- result( _, invoice, delivery_contact, NU ), string_to_upper(NU, NAME1).





