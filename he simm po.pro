%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - H E SIMM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( h_e_simm, `30 January 2015` ).

i_date_format( _ ).

i_user_field( invoice, street_two, `street two storage` ).

i_user_field( invoice, due_date_year, `due date year storage` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `GB-HESIMM` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]
	

	, [ q(0,3,line), get_invoice_type ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10576456` ) ]    %TEST
	    , suppliers_code_for_buyer( `12287412` )                      %PROD
	]) ]

	, get_delivery_address

	,[q0n(line), get_delivery_location ]

	,[q0n(line), get_delivery_contact ]
	
	, [q0n(line), get_shipping_instructions ]
	
%	, get_buyer_contact

	, get_buyer_email
	
	, buyer_ddi( `01517073222` )
	
	, buyer_fax( `01517073223` )

	,[q0n(line), get_order_number ]

     ,[q0n(line), get_invoice_date ]
	
	, [ q0n(line), get_due_date ]

	,[q0n(line), get_customer_comments ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	,[ qn0(line), invoice_total_line]
	
	, invoice_type( `ZE` )
	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER EMAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	  buyer_email( FROM )
	  
	, trace( [ `email`, buyer_email ] )
	  
	, buyer_contact( NAMES_SPACED )
	
	, trace( [ `buyer contact`, NAMES_SPACED ] )

] )
:-
	i_mail( from, FROM )
	, sys_string_split( FROM, `@`, [ NAMES|_ ]	)
	, string_string_replace( NAMES, `.`, ` `, NAMES_SPACED )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TYPE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_type, [ 
%=======================================================================

	`order`, `no`, `.`

	, dummy(sf), `/`

	, dummy(sf), `/`

	, dummy(sf), `/`

	, dummy(d)

	, invoice_type(`ZE`)

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_due_date, [ 
%=======================================================================

	`Delivery`, `Instructions`, tab

	, or( [ 

%		due_date( `17/06/2014` ), 

		[ due_date( date ), newline ]
	
		, [ q0n( word )
			
			, set( regexp_cross_word_boundaries )

			, due_date( f( [ begin, q(dec,1,2), end, q(alpha,0,2) ] ) )
			
			, clear( regexp_cross_word_boundaries )

%				, q10(`th`), q10(`st`)
			, q01( tab )

			, append( due_date(w), `/`, `` ) 

			, with( invoice, due_date_year, YEAR )

			, append( due_date( YEAR ), `/`, `` )

		]
			
		, [ q0n(word)
			, read_ahead( 
				or( [ `ASAP`
					, [ `Please`, `liaise` ]
				] )
			) 
		]

		, delivery_note_reference(`missing_date`)
			
	] )

	, trace([ `Due date`, due_date ])

	, or( [ 
		[ qn0(word)
			, or( [ `AM`	
				, [ `A`, `.`, `M`, `.` ]
				, [ `As`, `early`, `as`, `possible` ]
				, [ `Please`, `liaise` ]
				, `delivery` 
				, `ASAP`	
			] )
			
			, type_of_supply( `G1`)
		]

		, type_of_supply( `S0`)

	] )

	, trace([ `Type of Supply`, type_of_supply ])

	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delivery ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_delivery_address, [
%=======================================================================

	delivery_start_header

	, peek_ahead( gen_count_lines( [ end_of_deliver_to, COUNT ] ) )

	, deliver_to_details( COUNT, -5, 320 )

	, trace( [ `deliver to`, delivery_party, delivery_contact, delivery_address_line, delivery_city, delivery_county, delivery_postcode ] )
] ).

%=======================================================================
i_line_rule_cut( delivery_start_header, [
%=======================================================================

	`Supplier`, tab, `Delivery`, `Address`,  newline

	, trace([`delivery start header found`])

] ).

%=======================================================================
i_line_rule_cut( deliver_to_details, [
%=======================================================================

	  delivery_party(`H E SIMM & SON LTD`)
	  
	, q10( [ `C`, `/`, `o`, dummy(sf), `,` ] )

	, street_two(sf), `,`
	
	, q10( [ `C`, `/`, `o`, dummy(sf), `,` ] )
	
	, q(2,0,get_delivery_thing )
	
	, delivery_street(sf), `,`
	
	, delivery_city(sf), `,`
	
	, q01(maybe_delivery_state)
	
	, delivery_postcode(pc)
	
	, check( i_user_check( gen_same, street_two, TWO ) )
	
	, delivery_street( TWO )

] ).

%=======================================================================
i_line_rule( end_of_deliver_to, [ or([ [ q0n(anything), `=`] , [ `tel`, `:` ] ] ) ] ).
%=======================================================================


%=======================================================================
i_rule( maybe_delivery_state, [ delivery_state(sf), check( i_user_check( gen_recognised_county, delivery_state ) ) ] ).
%=======================================================================
i_rule_cut( get_delivery_thing, [ some_delivery_thing, end_of_delivery_thing ] ).
%=======================================================================
i_rule( some_delivery_thing, [ append( street_two(sf), `, `, `` ) ] ).
%=======================================================================
i_rule( end_of_delivery_thing, [ `,` ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	delivery_contact_header

	, q(2, 6, line)

	, delivery_contact_line

] ).

%=======================================================================
i_line_rule( delivery_contact_header, [ 
%=======================================================================

	`supplier`, tab, `delivery`, `address`, newline

] ).

%=======================================================================
i_line_rule( delivery_contact_line, [ 
%=======================================================================

	q0n(anything), q10( `Contact` )

	, delivery_contact(sf), or( [ `=`, `-`, `–`, other_dummy(f( q(other,1,1) ) ), read_ahead( dummy(d) ) ] )

	, delivery_ddi(s1), newline
	
	, check( delivery_ddi(start) > -50 )
	
	, check( delivery_ddi(y) > -320 )

	, trace( [ `delivery contact`, delivery_contact ] ) 

	, trace( [ `delivery ddi`, delivery_ddi ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [ 
%=======================================================================

	delivery_contact_header

	, q(2, 6, line)

	, shipping_instructions_line

] ).


%=======================================================================
i_line_rule( shipping_instructions_line, [ 
%=======================================================================

	q0n(anything)

	, shipping_instructions(s1)
	
	, check( shipping_instructions(start) > -50 ) 
	
	, check( shipping_instructions(y) > -320 )

	, trace( [ `shipping instructions`, shipping_instructions ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q0n(line), buyer_contact_line

] ).

%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	  `Authorised`, `Signature`, q10( tab )
	  
	, dummy(sf), q10( tab )
	
	, trace( [ `dummy`, dummy ] )
	
	, read_ahead( [ buyer_email(w) ] )
	
	, check( buyer_email(start) > -150 )
	
	, buyer_contact(w)
	
	, read_ahead( append( buyer_email(w), `.`, `@hesimm.co.uk` ) )
	
	, append( buyer_contact(w), ` `, `` )
	
	, trace( [ `buyer_contact`, buyer_contact, buyer_email ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	`order`, `no`, `.`
	
	, read_ahead( [ delivery_location(sf), `/` ] )

	, order_number(s1)

	, newline

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_date, [ 
%=======================================================================

	`order`, `date`, tab
	
	, read_ahead( [ qn0( [ word, `/`] ), due_date_year ] )

	, invoice_date(date)

	, trace( [ `order date`, invoice_date ] ) 
	
	, trace( [ `due date year`, due_date_year ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	customer_comments_header

	, customer_comments_line
] ).

%=======================================================================
i_line_rule( customer_comments_header, [ 
%=======================================================================

	`remarks`, newline

] ).

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	customer_comments(s1)

	, newline

	, trace( [ `customer comments`, customer_comments ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	`order`, `value`, tab, `£`

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

		, or([ 
		
			[ line_invoice_line, q10(line_continuation_line) ]
			
			, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `item`, `description`, tab, `catalogue` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`order`, `value`

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	line_descr(s), q10( tab )
	
	, check( line_descr(end) < -115 )

	, trace([ `line description`, line_descr ])

	, or( [ [ line_item(s1), tab ]
	
			, [ line_item( `Missing`)
			
				, delivery_note_reference( `item number missing`) 
				
			]
			
		] )

	, trace([ `line item`, line_item ])

	, line_quantity(d), q01(word), tab

	, trace([ `line quantity`, line_quantity ])

	,`£`, line_unit_amount(d), q01( [ dummy(s1) ] ), tab

	, trace( [ `line unit amount`, line_unit_amount ] )

	, line_percent_discount(d), tab

	, trace( [ `line percent discount`, line_percent_discount ] )

	,`£`, line_net_amount(d)

	, trace( [ `line net amount`, line_net_amount ] )

	, newline

	, q10([ with( invoice, due_date, DATE ), line_original_order_date( DATE ) ])
	
	, q10( [
	
			  check( i_user_check( check_for_uom, line_item, UOM ) )
			
			, line_quantity_uom_code( UOM )
			
			, trace( [ `looked up UOM` ] )
			
		] )


] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	append(line_descr(s1), ` `, ``), newline

] ).


%================================================================
%LOOKUP
%================================================================

i_user_check( check_for_uom, ITEM, UOM )
:-
	item_for_code( ITEM, UOM)
.


item_for_code( `Material`, `UoM` ).
item_for_code( `242169`, `M` ).
item_for_code( `247912`, `M` ).
item_for_code( `247915`, `M` ).
item_for_code( `303989`, `M` ).
item_for_code( `303990`, `M` ).
item_for_code( `303991`, `M` ).
item_for_code( `303992`, `M` ).
item_for_code( `303993`, `M` ).
item_for_code( `303994`, `M` ).
item_for_code( `303996`, `M` ).
item_for_code( `303997`, `M` ).
item_for_code( `303998`, `M` ).
item_for_code( `303999`, `M` ).
item_for_code( `304002`, `M` ).
item_for_code( `304003`, `M` ).
item_for_code( `304096`, `M` ).
item_for_code( `304097`, `M` ).
item_for_code( `304099`, `M` ).
item_for_code( `304100`, `M` ).
item_for_code( `304101`, `M` ).
item_for_code( `304102`, `M` ).
item_for_code( `304103`, `M` ).
item_for_code( `304104`, `M` ).
item_for_code( `304105`, `M` ).
item_for_code( `304107`, `M` ).
item_for_code( `304108`, `M` ).
item_for_code( `304109`, `M` ).
item_for_code( `304110`, `M` ).
item_for_code( `304112`, `M` ).
item_for_code( `304798`, `M` ).
item_for_code( `304799`, `M` ).
item_for_code( `304800`, `M` ).
item_for_code( `304801`, `M` ).
item_for_code( `369584`, `M` ).
item_for_code( `369585`, `M` ).
item_for_code( `369589`, `M` ).
item_for_code( `369590`, `M` ).
item_for_code( `369591`, `M` ).
item_for_code( `369592`, `M` ).
item_for_code( `369596`, `M` ).
item_for_code( `369597`, `M` ).
item_for_code( `369598`, `M` ).
item_for_code( `369599`, `M` ).
item_for_code( `369601`, `M` ).
item_for_code( `369602`, `M` ).
item_for_code( `369603`, `M` ).
item_for_code( `369604`, `M` ).
item_for_code( `369605`, `M` ).
item_for_code( `369606`, `M` ).
item_for_code( `370594`, `M` ).
item_for_code( `373795`, `M` ).
item_for_code( `373797`, `M` ).
item_for_code( `373799`, `M` ).
item_for_code( `376634`, `M` ).
item_for_code( `377781`, `M` ).
item_for_code( `377782`, `M` ).
item_for_code( `377830`, `M` ).
item_for_code( `384539`, `M` ).
item_for_code( `386478`, `M` ).
item_for_code( `406821`, `M` ).
item_for_code( `412782`, `M` ).
item_for_code( `412783`, `M` ).
item_for_code( `418748`, `M` ).
item_for_code( `418750`, `M` ).
item_for_code( `418751`, `M` ).
item_for_code( `418776`, `M` ).
item_for_code( `424757`, `M` ).
item_for_code( `424758`, `M` ).
item_for_code( `424769`, `M` ).
item_for_code( `424770`, `M` ).
item_for_code( `424771`, `M` ).
item_for_code( `424772`, `M` ).
item_for_code( `434584`, `M` ).
item_for_code( `439028`, `M` ).
item_for_code( `2005793`, `M` ).
item_for_code( `2006465`, `M` ).
item_for_code( `2006771`, `M` ).
item_for_code( `2008405`, `M` ).
item_for_code( `2012900`, `M` ).
item_for_code( `2014780`, `M` ).
item_for_code( `2019789`, `M` ).
item_for_code( `2019790`, `M` ).
item_for_code( `2020232`, `M` ).
item_for_code( `2020233`, `M` ).
item_for_code( `2020234`, `M` ).
item_for_code( `2023711`, `M` ).
item_for_code( `2029370`, `M` ).
item_for_code( `2029372`, `M` ).
item_for_code( `2029373`, `M` ).
item_for_code( `2029374`, `M` ).
item_for_code( `2029375`, `M` ).
item_for_code( `2029376`, `M` ).
item_for_code( `2029377`, `M` ).
item_for_code( `2029378`, `M` ).
item_for_code( `2029379`, `M` ).
item_for_code( `2029380`, `M` ).
item_for_code( `2029381`, `M` ).
item_for_code( `2029382`, `M` ).
item_for_code( `2029783`, `M` ).
item_for_code( `2029785`, `M` ).
item_for_code( `2029786`, `M` ).
item_for_code( `2029787`, `M` ).
item_for_code( `2029788`, `M` ).
item_for_code( `2029789`, `M` ).
item_for_code( `2029790`, `M` ).
item_for_code( `2029791`, `M` ).
item_for_code( `2029792`, `M` ).
item_for_code( `2029793`, `M` ).
item_for_code( `2029794`, `M` ).
item_for_code( `2029795`, `M` ).
item_for_code( `2029796`, `M` ).
item_for_code( `2029797`, `M` ).
item_for_code( `2030595`, `M` ).
item_for_code( `2030596`, `M` ).
item_for_code( `2030612`, `M` ).
item_for_code( `2030613`, `M` ).
item_for_code( `2030616`, `M` ).
item_for_code( `2030617`, `M` ).
item_for_code( `2030623`, `M` ).
item_for_code( `2030624`, `M` ).
item_for_code( `2030625`, `M` ).
item_for_code( `2030626`, `M` ).
item_for_code( `2030627`, `M` ).
item_for_code( `2030628`, `M` ).
item_for_code( `2030629`, `M` ).
item_for_code( `2030646`, `M` ).
item_for_code( `2030647`, `M` ).
item_for_code( `2030648`, `M` ).
item_for_code( `2030649`, `M` ).
item_for_code( `2030650`, `M` ).
item_for_code( `2030651`, `M` ).
item_for_code( `2030652`, `M` ).
item_for_code( `2030653`, `M` ).
item_for_code( `2030654`, `M` ).
item_for_code( `2030655`, `M` ).
item_for_code( `2030656`, `M` ).
item_for_code( `2030657`, `M` ).
item_for_code( `2030658`, `M` ).
item_for_code( `2030659`, `M` ).
item_for_code( `2030660`, `M` ).
item_for_code( `2030661`, `M` ).
item_for_code( `2030901`, `M` ).
item_for_code( `2030902`, `M` ).
item_for_code( `2035937`, `M` ).
item_for_code( `2037207`, `M` ).
item_for_code( `2037434`, `M` ).
item_for_code( `2047364`, `M` ).
item_for_code( `2048104`, `M` ).
item_for_code( `2049032`, `M` ).
item_for_code( `2049034`, `M` ).
item_for_code( `2050265`, `M` ).
item_for_code( `2050266`, `M` ).
item_for_code( `2050267`, `M` ).
item_for_code( `2050268`, `M` ).
item_for_code( `2054093`, `M` ).
item_for_code( `2054094`, `M` ).
item_for_code( `2054657`, `M` ).
item_for_code( `2057026`, `M` ).
item_for_code( `2057027`, `M` ).
item_for_code( `2057053`, `M` ).
item_for_code( `2057054`, `M` ).
item_for_code( `2057055`, `M` ).
item_for_code( `2059690`, `M` ).
item_for_code( `2069308`, `M` ).
item_for_code( `2069309`, `M` ).
item_for_code( `00242169`, `M` ).
item_for_code( `00247912`, `M` ).
item_for_code( `00247915`, `M` ).
item_for_code( `00303989`, `M` ).
item_for_code( `00303990`, `M` ).
item_for_code( `00303991`, `M` ).
item_for_code( `00303992`, `M` ).
item_for_code( `00303993`, `M` ).
item_for_code( `00303994`, `M` ).
item_for_code( `00303996`, `M` ).
item_for_code( `00303997`, `M` ).
item_for_code( `00303998`, `M` ).
item_for_code( `00303999`, `M` ).
item_for_code( `00304002`, `M` ).
item_for_code( `00304003`, `M` ).
item_for_code( `00304096`, `M` ).
item_for_code( `00304097`, `M` ).
item_for_code( `00304099`, `M` ).
item_for_code( `00304100`, `M` ).
item_for_code( `00304101`, `M` ).
item_for_code( `00304102`, `M` ).
item_for_code( `00304103`, `M` ).
item_for_code( `00304104`, `M` ).
item_for_code( `00304105`, `M` ).
item_for_code( `00304107`, `M` ).
item_for_code( `00304108`, `M` ).
item_for_code( `00304109`, `M` ).
item_for_code( `00304110`, `M` ).
item_for_code( `00304112`, `M` ).
item_for_code( `00304798`, `M` ).
item_for_code( `00304799`, `M` ).
item_for_code( `00304800`, `M` ).
item_for_code( `00304801`, `M` ).
item_for_code( `00369584`, `M` ).
item_for_code( `00369585`, `M` ).
item_for_code( `00369589`, `M` ).
item_for_code( `00369590`, `M` ).
item_for_code( `00369591`, `M` ).
item_for_code( `00369592`, `M` ).
item_for_code( `00369596`, `M` ).
item_for_code( `00369597`, `M` ).
item_for_code( `00369598`, `M` ).
item_for_code( `00369599`, `M` ).
item_for_code( `00369601`, `M` ).
item_for_code( `00369602`, `M` ).
item_for_code( `00369603`, `M` ).
item_for_code( `00369604`, `M` ).
item_for_code( `00369605`, `M` ).
item_for_code( `00369606`, `M` ).
item_for_code( `00370594`, `M` ).
item_for_code( `00373795`, `M` ).
item_for_code( `00373797`, `M` ).
item_for_code( `00373799`, `M` ).
item_for_code( `00376634`, `M` ).
item_for_code( `00377781`, `M` ).
item_for_code( `00377782`, `M` ).
item_for_code( `00377830`, `M` ).
item_for_code( `00384539`, `M` ).
item_for_code( `00386478`, `M` ).
item_for_code( `00406821`, `M` ).
item_for_code( `00412782`, `M` ).
item_for_code( `00412783`, `M` ).
item_for_code( `00418748`, `M` ).
item_for_code( `00418750`, `M` ).
item_for_code( `00418751`, `M` ).
item_for_code( `00418776`, `M` ).
item_for_code( `00424757`, `M` ).
item_for_code( `00424758`, `M` ).
item_for_code( `00424769`, `M` ).
item_for_code( `00424770`, `M` ).
item_for_code( `00424771`, `M` ).
item_for_code( `00424772`, `M` ).
item_for_code( `00434584`, `M` ).
item_for_code( `00439028`, `M` ).
item_for_code( `02005793`, `M` ).
item_for_code( `02006465`, `M` ).
item_for_code( `02006771`, `M` ).
item_for_code( `02008405`, `M` ).
item_for_code( `02012900`, `M` ).
item_for_code( `02014780`, `M` ).
item_for_code( `02019789`, `M` ).
item_for_code( `02019790`, `M` ).
item_for_code( `02020232`, `M` ).
item_for_code( `02020233`, `M` ).
item_for_code( `02020234`, `M` ).
item_for_code( `02023711`, `M` ).
item_for_code( `02029370`, `M` ).
item_for_code( `02029372`, `M` ).
item_for_code( `02029373`, `M` ).
item_for_code( `02029374`, `M` ).
item_for_code( `02029375`, `M` ).
item_for_code( `02029376`, `M` ).
item_for_code( `02029377`, `M` ).
item_for_code( `02029378`, `M` ).
item_for_code( `02029379`, `M` ).
item_for_code( `02029380`, `M` ).
item_for_code( `02029381`, `M` ).
item_for_code( `02029382`, `M` ).
item_for_code( `02029783`, `M` ).
item_for_code( `02029785`, `M` ).
item_for_code( `02029786`, `M` ).
item_for_code( `02029787`, `M` ).
item_for_code( `02029788`, `M` ).
item_for_code( `02029789`, `M` ).
item_for_code( `02029790`, `M` ).
item_for_code( `02029791`, `M` ).
item_for_code( `02029792`, `M` ).
item_for_code( `02029793`, `M` ).
item_for_code( `02029794`, `M` ).
item_for_code( `02029795`, `M` ).
item_for_code( `02029796`, `M` ).
item_for_code( `02029797`, `M` ).
item_for_code( `02030595`, `M` ).
item_for_code( `02030596`, `M` ).
item_for_code( `02030612`, `M` ).
item_for_code( `02030613`, `M` ).
item_for_code( `02030616`, `M` ).
item_for_code( `02030617`, `M` ).
item_for_code( `02030623`, `M` ).
item_for_code( `02030624`, `M` ).
item_for_code( `02030625`, `M` ).
item_for_code( `02030626`, `M` ).
item_for_code( `02030627`, `M` ).
item_for_code( `02030628`, `M` ).
item_for_code( `02030629`, `M` ).
item_for_code( `02030646`, `M` ).
item_for_code( `02030647`, `M` ).
item_for_code( `02030648`, `M` ).
item_for_code( `02030649`, `M` ).
item_for_code( `02030650`, `M` ).
item_for_code( `02030651`, `M` ).
item_for_code( `02030652`, `M` ).
item_for_code( `02030653`, `M` ).
item_for_code( `02030654`, `M` ).
item_for_code( `02030655`, `M` ).
item_for_code( `02030656`, `M` ).
item_for_code( `02030657`, `M` ).
item_for_code( `02030658`, `M` ).
item_for_code( `02030659`, `M` ).
item_for_code( `02030660`, `M` ).
item_for_code( `02030661`, `M` ).
item_for_code( `02030901`, `M` ).
item_for_code( `02030902`, `M` ).
item_for_code( `02035937`, `M` ).
item_for_code( `02037207`, `M` ).
item_for_code( `02037434`, `M` ).
item_for_code( `02047364`, `M` ).
item_for_code( `02048104`, `M` ).
item_for_code( `02049032`, `M` ).
item_for_code( `02049034`, `M` ).
item_for_code( `02050265`, `M` ).
item_for_code( `02050266`, `M` ).
item_for_code( `02050267`, `M` ).
item_for_code( `02050268`, `M` ).
item_for_code( `02054093`, `M` ).
item_for_code( `02054094`, `M` ).
item_for_code( `02054657`, `M` ).
item_for_code( `02057026`, `M` ).
item_for_code( `02057027`, `M` ).
item_for_code( `02057053`, `M` ).
item_for_code( `02057054`, `M` ).
item_for_code( `02057055`, `M` ).
item_for_code( `02059690`, `M` ).
item_for_code( `02069308`, `M` ).
item_for_code( `02069309`, `M` ).
item_for_code( _, `PC` ).
