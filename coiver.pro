%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - COIVER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( coiver, `03 July 2015` ).

i_date_format( _ ).

i_rules_file( `d_hilti_it_postcode.pro` ).

i_format_postcode( X, X ).


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

	, get_cig_cup
	
	,[q0n(line), get_delivery_address ]
	
	,or([ get_suppliers_code_for_buyer

		, delivery_note_reference(`special rule`) ])

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_fax ]

	,[q0n(line), get_buyer_email ]

	,[q0n(line), get_delivery_contact ]

	,[q0n(line), get_delivery_ddi ]

	,[q0n(line), get_delivery_email ]

%	,[q0n(line), get_delivery_fax ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

%	, customer_comments( `Customer Comments` )
	,[q0n(line), customer_comments_line ] 

%	, shipping_instructions( `Shipping Instructions` )
	,[q0n(line), shipping_instructions_line ]

	, get_invoice_lines

	,[q0n(line), get_invoice_totals ]

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_cig_cup, [
%=======================================================================

	q(0,40,line), generic_horizontal_details( [ [ at_start, `C`, `.`, `I`, `.`, `G`, `.` ], 200, cig, s1 ] )
	
	, q(0,4,line), generic_horizontal_details( [ [ at_start, `C`, `.`, `U`, `.`, `P`, `.` ], 200, cup, s1 ] )
	
	, check( cup = Cup )
	, check( cig = Cig )
	
	, check( strcat_list( [ `CIG:`, Cig, ` CUP:`, Cup ], AL ) )
	, delivery_address_line( AL )
	, trace( [ `Delivery Address Line`, delivery_address_line ] )
	
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

	, q01(line), get_delivery_dept_line( 1, 50, 500 )

	, q10([ q(0,2,line), get_delivery_address_line( 1, 50, 500 ) ])

	, q01(line), get_delivery_street_line( 1, 50, 500 )

	, q01(line), get_delivery_postcode_city_line( 1, 50, 500 )

	, q01(line), get_delivery_state_line( 1, 50, 500 )
		
	, q10( [ without( delivery_postcode )
	
		, postcode_lookup_rule
		
	] )
 
] ).

%=======================================================================
i_line_rule( get_delivery_header_line, [
%=======================================================================
	
	q0n(anything) 

	,`Destinazione`, `merce`,  newline

	, trace([ `delivery header found ` ])

] ).

%=======================================================================
i_line_rule_cut( get_delivery_dept_line, [
%=======================================================================
	
	  delivery_dept(s1)

	, newline

	, trace([ `delivery dept`, delivery_dept ])

] ).

%=======================================================================
i_line_rule_cut( get_delivery_address_line, [
%=======================================================================
 
	  delivery_address_line(s1)

	, newline

	, trace([ `delivery address line`, delivery_address_line ])

] ).

%=======================================================================
i_line_rule_cut( get_delivery_street_line, [
%=======================================================================
 
	  delivery_street(s)

	, newline

	, trace([ `delivery street`, delivery_street ])

] ).

%=======================================================================
i_line_rule_cut( get_delivery_postcode_city_line, [
%=======================================================================
 
	  q10( [ delivery_postcode( f( [ begin, q(dec, 4,8), end ]) ), q10(tab)

		, trace([ `delivery postcode`, delivery_postcode ])
	
	] )

	, delivery_city(s1)

	, newline

	, trace([ `delivery city`, delivery_city ])

] ).

%=======================================================================
i_line_rule( get_delivery_state_line, [
%=======================================================================
 
	  q0n(anything), delivery_state( f( [ begin, q(alpha, 2, 3), end ]) ) 

	, trace([ `delivery state`, delivery_state ])

] ).

%=======================================================================
i_rule_cut( postcode_lookup_rule, [
%=======================================================================	  
	 	
	  check( i_user_check( find_the_postcode, PC, delivery_city, delivery_state, Unknown ) )
	
	, delivery_postcode( PC )
	
	, trace( [ `delivery postcode from lookup`, delivery_postcode ] )

] ).

%=======================================================================
i_user_check( find_the_postcode, PC, City_L, State, Unknown )
%---------------------------------------
:-
%=======================================================================

	  string_to_upper( City_L, City )
	
	,(	postcode_lookup( PC, City, State, _ )
	
		;   postcode_lookup( PC, City, _, _ )
	
		;	PC = `Missing` 
	
	), !
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	buyer_contact(`Isidoro Tomezzoli`)

	, trace([ `buyer contact`, buyer_contact ])


] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	buyer_ddi(`0266301899`)

	, trace([ `buyer ddi`, buyer_ddi ])

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	buyer_email(`i.tomezzoli@coiver.it`)

	, trace([ `buyer email`, buyer_email ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_contact, [ 
%=======================================================================

	delivery_contact(`Isidoro Tomezzoli`)

	, trace([ `delivery contact`, delivery_contact ])


] ).

%=======================================================================
i_line_rule( get_delivery_ddi, [ 
%=======================================================================

	delivery_ddi(`0266301899`)

	, trace([ `delivery ddi`, delivery_ddi ])

] ).

%=======================================================================
i_line_rule( get_delivery_email, [ 
%=======================================================================

	delivery_email(`i.tomezzoli@coiver.it`)

	, trace([ `delivery email`, delivery_email ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIER CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [ q(10,300,line), suppliers_code_for_buyer_line ] ).
%=======================================================================
i_line_rule( suppliers_code_for_buyer_line, [ 
%=======================================================================

	read_ahead( [ q0n(word), Search ] )
	
	, generic_item( [ delivery_party, s1 ] )
	
	, q10( [ check( delivery_party = Party )
		, check( string_to_upper( Party, PartyU ) )
		, check( q_sys_sub_string( Party, 1, _, `CONTRACT` ) )
		, prepend( delivery_party( `COIVER ` ), ``, `` )
	] )
		
	, q10( [ check( delivery_party = Party )
		, check( string_to_upper( Party, PartyU ) )
		, check( q_sys_sub_string( Party, 1, _, `CENTRO SRL` ) )
		, prepend( delivery_party( `COIVER CONTRACT ` ), ``, `` )
	] )
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( SCFB_Test ) ]
	
		, suppliers_code_for_buyer( SCFB_Live )
		
	] )	
	
	, trace( [ `Delivery Party (final)`, delivery_party ] )

] )
:-
	scfb_lookup( Search, SCFB_Test, SCFB_Live )
.


scfb_lookup( [ `centro`, `srl` ], `10672877`, `16497061` ).
scfb_lookup( [ `contract`, or( [ [ `s`, `.`, `r`, `.`, `l`, `.` ], [ `SRL` ] ] ) ], `10658906`, `13023165` ).
scfb_lookup( [ `TERMOACUSTICHE`, `SR` ], `13044601`, `13044601` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	`Ordine`, `n`, `.`

	, order_number(s1)

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

	q0n(anything)

	, `del`, tab
	
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
i_line_rule( customer_comments_line, [ 
%=======================================================================

	`progetto`, tab
	
	, customer_comments(s), tab

	, append(customer_comments(s), ` `, ``)

	, newline

	, trace( [ `customer comments`, customer_comments ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( shipping_instructions_line, [ 
%=======================================================================

	`progetto`, tab
	
	, shipping_instructions(s), tab

	, append(shipping_instructions(s), ` `, ``)

	, newline

	, trace( [ `shipping instructions`, shipping_instructions ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_totals, [
%=======================================================================

	`Totale`, `ordine`, tab, `EUR`, tab

	, read_ahead(total_net(d))

	, trace( [ `total net`, total_net ] )

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
i_line_rule_cut( line_header_line, [ `Pos`, `.`, `Cod`, `.`, `prodotto`, tab, `UM` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Totale`, `ordine`, tab, `EUR`, tab

] ).

%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	get_invoice_values_line

	, q10(read_ahead(line_descr_line))

	,or([ quantity_and_code_line

		, [ quantity_line, q(0,2,line), code_line ]

		, [ q(0,2,line), code_line, line_quantity_b(`1`) ]

		, line_quantity_b(`1`) 

	])

	, trace([`line quantity B`, line_quantity_b ])

	, check( i_user_check( gen_str_multiply, line_quantity_a, line_quantity_b, QUANTITY ) )

	, line_quantity(QUANTITY)

	, trace([`line quantity`, line_quantity ])

	

] ).

%=======================================================================
i_line_rule_cut( get_invoice_values_line, [
%=======================================================================

	line_order_line_number(d), tab

	, line_item_for_buyer(s), tab

	, trace([`line item for buyer`, line_item_for_buyer ])

	, line_quantity_uom_code(w), tab

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, line_quantity_a(d)

	, trace([`line quantity A`, line_quantity_a ])

	, q0n(anything)

	, line_net_amount(d), tab

	, trace([`line net amount`, line_net_amount ])

	, line_original_order_date(date)

	, trace([`line orginal order date amount`, line_original_order_date ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( code_line, [
%=======================================================================

	qn0(anything)

	, or([ `cod`, `art`, `ARTICOLO` ]), q10(`.`), line_item(w)

	, trace([`line item`, line_item ])

	, newline


] ).


%=======================================================================
i_line_rule_cut( quantity_line, [
%=======================================================================

	q0n(anything)	

	, or([ `da`, `conf` ]), q10(`.`)

	, line_quantity_b(d)


] ).


%=======================================================================
i_line_rule_cut( quantity_and_code_line, [
%=======================================================================

	q0n(anything)	

	, or([ `da`, `conf` ]), q10(`.`)

	, line_quantity_b(d)

	, qn0(anything)

	, or([ `cod`, `art`, `ARTICOLO` ]), q10(`.`), line_item(w)

	, trace([`line item`, line_item ])

	, newline


] ).


%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================
	
	line_descr(s1), newline

	, trace([ `line deescription`, line_descr ])


] ).

