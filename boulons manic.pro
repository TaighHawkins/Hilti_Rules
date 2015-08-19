%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BOULANS MANIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( boulons_manic, `15 May 2015` ).

i_format_postcode( X, X ).

i_date_format( 'd/m/y' ).

i_user_field(invoice, internal_note, `Note` ).
i_user_field(invoice, packaging, `Packaging` ).
i_user_field(invoice, picking, `Picking` ).

i_orders05_idocs_e1edkt1( `Z003`, internal_note).
i_orders05_idocs_e1edkt1( `Z011`, packaging ).
i_orders05_idocs_e1edkt1( `Z012`, picking ).

i_user_field( line, line_item_098, `Line Item 098` ).
bespoke_e1edp19_segment( [ `098`, line_item_098 ] ).

i_op_param( output, _, _, _, orders05_idoc_xml ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `CA-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`CA_ADAPTRIS`)
	, agent_code_3(`6800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, type_of_supply(`01`)
	, cost_centre(`Standard`)

	, [ or([ 
	  [ test(hilti_live), suppliers_code_for_buyer( `10424161` ) ]    %TEST
	    , suppliers_code_for_buyer( `10684543` )                      %PROD
	]) ]

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

	,[q0n(line), get_werks_number ]

	,[q0n(line), get_order_date ]

	,[ q0n(line), get_general_original_order_date]

	, get_invoice_lines

	,[q0n(line), get_invoice_totals]

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERAL ORIGINAL ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_general_original_order_date, [ 
%=======================================================================

	q0n(anything)

	, `req`, `date`, tab

	, due_date(date(`d/m/y`))

	, trace([ `due date`, due_date ])
	
	, newline

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WERKS NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_werks_number, [ 
%=======================================================================

	q0n(anything)

	, `status`, tab

	, `rush`

	, newline

	, set(werks)

	, customer_comments(`Rush`), shipping_instructions(`Rush`) 
	, internal_note(`Rush`), packaging(`Rush`), picking(`Rush`)  


]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  get_delivery_header_line

	, q(0, 2, line), get_delivery_party_line

	, q(0, 2, line), get_delivery_street_line

	, get_delivery_city_state_line

	, q01(line), get_delivery_postcode_line

] ).

%=======================================================================
i_line_rule( get_delivery_header_line, [
%=======================================================================
 
	q0n(anything)

	, `shiped`, `to`, `:`, newline

	, trace([ `delivery header found ` ])

] ).

%=======================================================================
i_line_rule( get_delivery_party_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_party(s1)

	, check(delivery_party(start) > 50 )

	, trace([ `delivery party`, delivery_party ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_street_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_street(s1)

	, check(delivery_street(start) > 50 )

	, trace([ `delivery street`, delivery_street ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_city_state_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_city(s)

	, check(delivery_city(start) > 50 )

	, trace([ `delivery city`, delivery_city ])

	, delivery_state(w)

	, trace([ `delivery state`, delivery_state ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_postcode_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_postcode(s1)

	, check(delivery_postcode(start) > 50 )

	, newline
	
	, trace( [ `Delivery Postcode`, delivery_postcode ] )

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

	, `contact`, `:`, tab

	, buyer_contact(s1)

	, trace([ `buyer contact`, buyer_contact ])

	, tab, `supplier`, `#`

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	`Tél`, `.`, `:`, `(`

	, buyer_ddi(w), `)`

	, append(buyer_ddi(`-`), ``, ``)

	, append(buyer_ddi(s), ``, ``)

	, trace([ `buyer ddi`, buyer_ddi ])

	, `fax`, `:`

] ).

%=======================================================================
i_line_rule( get_buyer_fax, [ 
%=======================================================================

	q0n(anything)

	, `fax`, `:`,`(`

	, buyer_fax(w), `)`

	, append(buyer_fax(`-`), ``, ``)

	, append(buyer_fax(s), ``, ``)

	, trace([ `buyer fax`, buyer_fax ])

	, newline

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
i_line_rule( get_delivery_contact, [ 
%=======================================================================

	q0n(anything)

	, `contact`, `:`, tab

	, delivery_contact(s1)

	, trace([ `delivery contact`, delivery_contact ])

	, tab, `supplier`, `#`

] ).

%=======================================================================
i_line_rule( get_delivery_ddi, [ 
%=======================================================================

	`Tél`, `.`, `:`, `(`

	, delivery_ddi(w), `)`

	, append(delivery_ddi(`-`), ``, ``)

	, append(delivery_ddi(s), ``, ``)

	, trace([ `delivery ddi`, delivery_ddi ])

	, `fax`, `:`

] ).

%=======================================================================
i_line_rule( get_delivery_fax, [ 
%=======================================================================

	q0n(anything)

	, `fax`, `:`,`(`

	, delivery_fax(w), `)`

	, append(delivery_fax(`-`), ``, ``)

	, append(delivery_fax(s), ``, ``)

	, trace([ `delivery fax`, delivery_fax ])

	, newline

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
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything)

	,`order`, `#`, tab

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

	, newline

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

	,`order`, `date`, tab

	, invoice_date(date(`d/m/y`))

	, trace( [ `order number`, invoice_date ] ) 

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_totals, [
%=======================================================================

	`subtotal`, `before`, `tax`, tab

	, read_ahead(total_net(d))

	, total_invoice(d)

	, trace( [ `total net`, total_net ] )	

	, trace( [ `total invoice`, total_invoice ] )	

	, newline

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

		, or([ line_invoice_line_one, line_invoice_line_two, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ or( [ [ `MUNAF`, `.` ], `MGF` ] ), `#`, tab, `PRODUCT`, `#`, tab, `DESCRIPTION` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `subtotal`, `before`, `tax`, tab ]
	
			, [ `Page`, q10( tab ), num(d), q10( tab ), `/` ]
			
	] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_one, [
%=======================================================================

	line_order_line_number(d)

	, trace([`line order line number`, line_order_line_number])

	, read_ahead( my_item(w) ), trace([`item lookup`, my_item ])
	, check( i_user_check( get_boulons_quantity, my_item, SIZE, PACK ) )
	, trace([`line item in table`, my_item ])

	, line_item(d), tab

	, product(s1), tab

	, line_descr(s1), tab

	, trace([`line descr`, line_descr ])

	, my_quantity(d)
	, trace([`line quantity read`, my_quantity ])
	, check( i_user_check( gen_str_divide, my_quantity, SIZE, LQ1 ) )
	, check( i_user_check( gen_str_add, LQ1, `0.49`, LQ2 ) )
	, check( sys_calculate_str_round_0( LQ2, LQ3 ) )
	, line_quantity(LQ3)

	, trace([`line quantity`, line_quantity ])

	, read_ahead( line_quantity_uom_code_x(w) ), `UN`, tab

	, trace([`line quantity uom code`, line_quantity_uom_code_x ])

	, unitamount(d), tab

	, line_net_amount(d), line_vat_amount(`0`)

	, trace([`line net amount`, line_net_amount ])

%	, with( invoice, due_date, DATE )

%	, line_original_order_date( DATE )

%	, trace( [ `original order date set to`, line_original_order_date ] )

	, newline

	, q10([ test(werks) , line_delivery_note_number(`6854`)

	, trace([ `werks`, line_delivery_note_number ]) ])
	
	, check( line_item = Item )
	, line_item_098( Item )
	, trace( [ `Line item 098`, line_item_098 ] )

] ).


%=======================================================================
i_line_rule_cut( line_invoice_line_two, [
%=======================================================================

	line_order_line_number(d)

	, trace([`line order line number`, line_order_line_number])

	, or([ line_item(d), line_item(`Missing`) ]), tab

	, product(s1), tab

	, line_descr(s1), tab

	, trace([`line descr`, line_descr ])

	, line_quantity(d)

	, trace([`line quantity`, line_quantity ])

	, q10( [ read_ahead( `UN` ), read_ahead( generic_item( [ line_quantity_uom_code, w ] ) ) ] )
	, read_ahead( line_quantity_uom_code_x(w) ), word, tab

	, trace([`line quantity uom code`, line_quantity_uom_code_x ])

	, unitamount(d), tab

	, line_net_amount(d), line_vat_amount(`0`)

	, trace([`line net amount`, line_net_amount ])

%	, with( invoice, due_date, DATE )

%	, line_original_order_date( DATE )

%	, trace( [ `original order date set to`, line_original_order_date ] )

	, newline

	, q10([ test(werks) , line_delivery_note_number(`6854`)

	, trace([ `werks`, line_delivery_note_number ]) ])

	, check( line_item = Item )
	, line_item_098( Item )
	, trace( [ `Line item 098`, line_item_098 ] )
	
] ).



i_user_check( get_boulons_quantity, ITEM, SIZE, PACK ) :- boulons_quantity( ITEM, SIZE, PACK ).


boulons_quantity( `40643`, `150`, `BOX`).
boulons_quantity( `50107`, `100`, `BOX`).
boulons_quantity( `50115`, `1000`, `BOX`).
boulons_quantity( `50116`, `1000`, `BOX`).
boulons_quantity( `50351`, `100`, `BOX`).
boulons_quantity( `50352`, `100`, `BOX`).
boulons_quantity( `50353`, `100`, `BOX`).
boulons_quantity( `50372`, `1000`, `BOX`).
boulons_quantity( `50373`, `1000`, `BOX`).
boulons_quantity( `50606`, `100`, `BOX`).
boulons_quantity( `66370`, `25`, `BOX`).
boulons_quantity( `66371`, `25`, `BOX`).
boulons_quantity( `68661`, `5`, `BOX`).
boulons_quantity( `203852`, `10`, `PACKAGE`).
boulons_quantity( `203857`, `5`, `PACKAGE`).
boulons_quantity( `203859`, `5`, `PACKAGE`).
boulons_quantity( `237330`, `100`, `BOX`).
boulons_quantity( `237331`, `100`, `BOX`).
boulons_quantity( `237333`, `100`, `BOX`).
boulons_quantity( `237334`, `100`, `BOX`).
boulons_quantity( `237335`, `100`, `BOX`).
boulons_quantity( `237336`, `100`, `BOX`).
boulons_quantity( `237337`, `100`, `BOX`).
boulons_quantity( `237338`, `100`, `BOX`).
boulons_quantity( `237339`, `100`, `BOX`).
boulons_quantity( `237340`, `100`, `BOX`).
boulons_quantity( `237342`, `100`, `BOX`).
boulons_quantity( `237344`, `100`, `BOX`).
boulons_quantity( `237345`, `100`, `BOX`).
boulons_quantity( `237346`, `100`, `BOX`).
boulons_quantity( `237347`, `100`, `BOX`).
boulons_quantity( `237348`, `100`, `BOX`).
boulons_quantity( `237349`, `100`, `BOX`).
boulons_quantity( `237350`, `100`, `BOX`).
boulons_quantity( `237351`, `100`, `BOX`).
boulons_quantity( `237352`, `100`, `BOX`).
boulons_quantity( `237353`, `100`, `BOX`).
boulons_quantity( `237354`, `100`, `BOX`).
boulons_quantity( `237356`, `100`, `BOX`).
boulons_quantity( `241383`, `20`, `BOX`).
boulons_quantity( `249696`, `100`, `BOX`).
boulons_quantity( `252011`, `50`, `BOX`).
boulons_quantity( `255990`, `50`, `BOX`).
boulons_quantity( `256692`, `10`, `BOX`).
boulons_quantity( `256693`, `10`, `BOX`).
boulons_quantity( `256694`, `10`, `BOX`).
boulons_quantity( `256695`, `5`, `BOX`).
boulons_quantity( `256696`, `5`, `BOX`).
boulons_quantity( `256699`, `4`, `BOX`).
boulons_quantity( `256702`, `5`, `BOX`).
boulons_quantity( `260347`, `200`, `BOX`).
boulons_quantity( `271969`, `100`, `BOX`).
boulons_quantity( `271971`, `100`, `BOX`).
boulons_quantity( `282502`, `100`, `BOX`).
boulons_quantity( `282503`, `100`, `BOX`).
boulons_quantity( `282504`, `100`, `BOX`).
boulons_quantity( `282505`, `50`, `BOX`).
boulons_quantity( `282509`, `25`, `BOX`).
boulons_quantity( `282513`, `15`, `BOX`).
boulons_quantity( `282520`, `10`, `BOX`).
boulons_quantity( `282521`, `100`, `BOX`).
boulons_quantity( `282522`, `50`, `BOX`).
boulons_quantity( `282523`, `50`, `BOX`).
boulons_quantity( `282524`, `50`, `BOX`).
boulons_quantity( `282525`, `50`, `BOX`).
boulons_quantity( `282526`, `25`, `BOX`).
boulons_quantity( `282527`, `25`, `BOX`).
boulons_quantity( `282528`, `25`, `BOX`).
boulons_quantity( `282529`, `25`, `BOX`).
boulons_quantity( `282530`, `15`, `BOX`).
boulons_quantity( `282531`, `15`, `BOX`).
boulons_quantity( `282532`, `15`, `BOX`).
boulons_quantity( `282533`, `15`, `BOX`).
boulons_quantity( `282534`, `15`, `BOX`).
boulons_quantity( `282535`, `10`, `BOX`).
boulons_quantity( `282536`, `10`, `BOX`).
boulons_quantity( `282537`, `10`, `BOX`).
boulons_quantity( `282538`, `10`, `BOX`).
boulons_quantity( `282539`, `100`, `BOX`).
boulons_quantity( `282540`, `100`, `BOX`).
boulons_quantity( `282541`, `100`, `BOX`).
boulons_quantity( `282542`, `50`, `BOX`).
boulons_quantity( `282552`, `15`, `BOX`).
boulons_quantity( `282553`, `100`, `BOX`).
boulons_quantity( `282554`, `50`, `BOX`).
boulons_quantity( `282555`, `50`, `BOX`).
boulons_quantity( `282556`, `50`, `BOX`).
boulons_quantity( `282558`, `25`, `BOX`).
boulons_quantity( `282559`, `25`, `BOX`).
boulons_quantity( `282560`, `25`, `BOX`).
boulons_quantity( `282564`, `15`, `BOX`).
boulons_quantity( `282567`, `50`, `BOX`).
boulons_quantity( `282573`, `15`, `BOX`).
boulons_quantity( `283549`, `20`, `BOX`).
boulons_quantity( `286017`, `5`, `BOX`).
boulons_quantity( `286018`, `5`, `BOX`).
boulons_quantity( `286019`, `5`, `BOX`).
boulons_quantity( `286021`, `20`, `BOX`).
boulons_quantity( `286025`, `20`, `BOX`).
boulons_quantity( `286027`, `10`, `BOX`).
boulons_quantity( `286037`, `100`, `BOX`).
boulons_quantity( `286038`, `100`, `BOX`).
boulons_quantity( `286040`, `100`, `BOX`).
boulons_quantity( `286041`, `100`, `BOX`).
boulons_quantity( `332108`, `250`, `BOX`).
boulons_quantity( `332682`, `100`, `BOX`).
boulons_quantity( `332683`, `100`, `BOX`).
boulons_quantity( `332686`, `100`, `BOX`).
boulons_quantity( `333308`, `10`, `BOX`).
boulons_quantity( `333309`, `10`, `BOX`).
boulons_quantity( `335506`, `150`, `BOX`).
boulons_quantity( `335507`, `100`, `BOX`).
boulons_quantity( `335508`, `100`, `BOX`).
boulons_quantity( `336248`, `50`, `BOX`).
boulons_quantity( `336427`, `50`, `BOX`).
boulons_quantity( `336428`, `25`, `BOX`).
boulons_quantity( `336429`, `25`, `BOX`).
boulons_quantity( `336430`, `100`, `BOX`).
boulons_quantity( `336431`, `50`, `BOX`).
boulons_quantity( `336432`, `50`, `BOX`).
boulons_quantity( `336433`, `25`, `BOX`).
boulons_quantity( `336434`, `25`, `BOX`).
boulons_quantity( `336931`, `50`, `BOX`).
boulons_quantity( `336932`, `25`, `BOX`).
boulons_quantity( `338725`, `12`, `BOX`).
boulons_quantity( `340234`, `750`, `BOX`).
boulons_quantity( `343760`, `100`, `BOX`).
boulons_quantity( `370635`, `5`, `BOX`).
boulons_quantity( `371788`, `6`, `BOX`).
boulons_quantity( `371807`, `20`, `BOX`).
boulons_quantity( `371808`, `20`, `BOX`).
boulons_quantity( `374496`, `100`, `BOX`).
boulons_quantity( `377883`, `50`, `BOX`).
boulons_quantity( `377884`, `50`, `BOX`).
boulons_quantity( `377885`, `50`, `BOX`).
boulons_quantity( `378083`, `25`, `BOX`).
boulons_quantity( `378084`, `25`, `BOX`).
boulons_quantity( `378088`, `15`, `BOX`).
boulons_quantity( `378089`, `10`, `BOX`).
boulons_quantity( `378090`, `10`, `BOX`).
boulons_quantity( `385418`, `10`, `PACKAGE`).
boulons_quantity( `385419`, `20`, `PACKAGE`).
boulons_quantity( `385420`, `10`, `PACKAGE`).
boulons_quantity( `385422`, `10`, `PACKAGE`).
boulons_quantity( `385423`, `10`, `PACKAGE`).
boulons_quantity( `385424`, `20`, `PACKAGE`).
boulons_quantity( `385425`, `10`, `PACKAGE`).
boulons_quantity( `385427`, `10`, `PACKAGE`).
boulons_quantity( `385428`, `20`, `PACKAGE`).
boulons_quantity( `385429`, `10`, `PACKAGE`).
boulons_quantity( `385432`, `10`, `PACKAGE`).
boulons_quantity( `385436`, `10`, `PACKAGE`).
boulons_quantity( `385462`, `20`, `PACKAGE`).
boulons_quantity( `385469`, `10`, `PACKAGE`).
boulons_quantity( `385471`, `10`, `PACKAGE`).
boulons_quantity( `387509`, `50`, `BOX`).
boulons_quantity( `387510`, `50`, `BOX`).
boulons_quantity( `387511`, `50`, `BOX`).
boulons_quantity( `387512`, `20`, `BOX`).
boulons_quantity( `387513`, `20`, `BOX`).
boulons_quantity( `387515`, `20`, `BOX`).
boulons_quantity( `387519`, `15`, `BOX`).
boulons_quantity( `387524`, `50`, `BOX`).
boulons_quantity( `387529`, `20`, `BOX`).
boulons_quantity( `387530`, `15`, `BOX`).
boulons_quantity( `388504`, `1000`, `BOX`).
boulons_quantity( `388505`, `100`, `BOX`).
boulons_quantity( `388518`, `100`, `BOX`).
boulons_quantity( `388521`, `100`, `BOX`).
boulons_quantity( `388524`, `100`, `BOX`).
boulons_quantity( `388525`, `100`, `BOX`).
boulons_quantity( `388535`, `100`, `BOX`).
boulons_quantity( `388537`, `100`, `BOX`).
boulons_quantity( `401397`, `25`, `BOX`).
boulons_quantity( `401398`, `25`, `BOX`).
boulons_quantity( `403902`, `5`, `BOX`).
boulons_quantity( `409492`, `100`, `BOX`).
boulons_quantity( `409499`, `100`, `BOX`).
boulons_quantity( `412590`, `20`, `BOX`).
boulons_quantity( `412669`, `100`, `BOX`).
boulons_quantity( `418045`, `100`, `BOX`).
boulons_quantity( `418046`, `100`, `BOX`).
boulons_quantity( `418047`, `100`, `BOX`).
boulons_quantity( `418048`, `100`, `BOX`).
boulons_quantity( `418056`, `50`, `BOX`).
boulons_quantity( `418059`, `50`, `BOX`).
boulons_quantity( `418070`, `30`, `BOX`).
boulons_quantity( `418077`, `25`, `BOX`).
boulons_quantity( `418080`, `15`, `BOX`).
boulons_quantity( `418081`, `15`, `BOX`).
boulons_quantity( `423178`, `20`, `BOX`).
boulons_quantity( `423473`, `100`, `BOX`).
boulons_quantity( `433003`, `100`, `BOX`).
boulons_quantity( `433006`, `100`, `BOX`).
boulons_quantity( `433009`, `100`, `BOX`).
boulons_quantity( `433015`, `100`, `BOX`).
boulons_quantity( `433020`, `100`, `BOX`).
boulons_quantity( `433021`, `100`, `BOX`).
boulons_quantity( `433022`, `100`, `BOX`).
boulons_quantity( `433023`, `100`, `BOX`).
boulons_quantity( `433029`, `100`, `BOX`).
boulons_quantity( `433032`, `100`, `BOX`).
boulons_quantity( `436656`, `25`, `BOX`).
boulons_quantity( `2025921`, `8`, `PACKAGE`).
boulons_quantity( `2025923`, `32`, `PACKAGE`).
boulons_quantity( `2025925`, `32`, `PACKAGE`).
boulons_quantity( `2025926`, `32`, `PACKAGE`).
boulons_quantity( `2025927`, `32`, `PACKAGE`).
boulons_quantity( `2058129`, `50`, `BOX`).
boulons_quantity( `41070`, `100`, `BOX`).
boulons_quantity( `68613`, `10`, `PACKAGE`).
boulons_quantity( `88977`, `10`, `PACKAGE`).
boulons_quantity( `88979`, `10`, `PACKAGE`).
boulons_quantity( `219887`, `100`, `BOX`).
boulons_quantity( `219888`, `100`, `BOX`).
boulons_quantity( `286511`, `10000`, `BOX`).
boulons_quantity( `374714`, `10`, `PACKAGE`).
boulons_quantity( `374715`, `10`, `PACKAGE`).
boulons_quantity( `407299`, `5`, `BOX`).
boulons_quantity( `407310`, `5`, `BOX`).
boulons_quantity( `407314`, `2`, `BOX`).
boulons_quantity( `409493`, `50`, `BOX`).
boulons_quantity( `434908`, `6`, `PACKAGE`).
boulons_quantity( `434991`, `24`, `PACKAGE`).
