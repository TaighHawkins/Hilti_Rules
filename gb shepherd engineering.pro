%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - SHEPHERD ENGINEERING SERVICES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( shepherd_engineering_services, `15 July 2015` ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).

i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).
i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_invoice_date

	, get_buyer_email
	
	, get_buyer_ddi
	
	, get_delivery_contact
	
	, get_delivery_ddi

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `GB-SHEPENG` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Shepherd Engineering Services Ltd.` )
	, delivery_party( `SHEPHERD ENGINEERING SERVICES` )
	
	, suppliers_code_for_buyer( `12277668` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Order`, `No` ], order_number, s1 ] )
	  
	, check( sys_string_split( order_number, `/`, [ Loc | _ ] ) )
	, delivery_location( Loc )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Order`, `Date` ], invoice_date, date ] ) 
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	buyer_email( Email )
	, buyer_contact( Con )

] )
:-
	i_mail( from, From ),
	string_to_lower( From, FromL ),
	not( q_sys_sub_string( FromL, _, _, `@hilti.com` ) ),
	( email_contact_lookup( FromL, Con )
		->	Email = From
		
		;	Email = `gcole@ses-ltd.co.uk`,
			email_contact_lookup( Email, Con )
	)
.

email_contact_lookup( `narmstrong@ses-ltd.co.uk`, `Neil Armstrong` ).
email_contact_lookup( `aratcliffe@ses-ltd.co.uk`, `ALISTER ATCLIFFE` ).
email_contact_lookup( `abagley@ses-ltd.co.uk`, `ADAM BAGLEY` ).
email_contact_lookup( `abarnes@shepherdbe.com`, `Annette Barnes` ).
email_contact_lookup( `mbaxendale@shepherdbe.com`, `MICHELLE BAXENDALE` ).
email_contact_lookup( `cbeavers@ses-ltd.co.uk`, `CATHERINE BEAVERS` ).
email_contact_lookup( `pbone@ses-ltd.co.uk`, `peter bone` ).
email_contact_lookup( `mbostock@ses-ltd.co.uk`, `MARK BOSTOCK` ).
email_contact_lookup( `sjbrown@ses-ltd.co.uk`, `Stephanie Brown` ).
email_contact_lookup( `sjbrown@ses-ltd.co.uk`, `STEPH BROWN` ).
email_contact_lookup( `dcallaghan@ses-ltd.co.uk`, `DEAN CALLAGHAN` ).
email_contact_lookup( `mcarrick@ses-ltd.co.uk`, `Mike Carrick` ).
email_contact_lookup( `ccatterall@ses-ltd.co.uk`, `CHRIS CATTERALL` ).
email_contact_lookup( `dcattle@ses-ltd.co.uk`, `Danny Cattle` ).
email_contact_lookup( `dcattle@ses-ltd.co.uk`, `DANNY CATTLE` ).
email_contact_lookup( `sclarke@ses-ltd.co.uk`, `STEVE CLARKE` ).
email_contact_lookup( `gcole@ses-ltd.co.uk`, `Gary Cole` ).
email_contact_lookup( `pcole@ses-ltd.co.uk`, `Peter Cole` ).
email_contact_lookup( `pcole@ses-ltd.co.uk`, `Peter Cole` ).
email_contact_lookup( `lcooper2@sheperdbe.com`, `LUCY COOPER` ).
email_contact_lookup( `ccowlard@ses-ltd.co.uk`, `Chris Cowlard` ).
email_contact_lookup( `dbarker@ses-ltd.co.uk`, `Barker Danny` ).
email_contact_lookup( `adavidson@ses-ltd.co.uk`, `Alan Davidson` ).
email_contact_lookup( `sesinvoicing@ses-ltd.co.uk`, `LYNN EBILL` ).
email_contact_lookup( `pedwards@ses-ltd.co.uk`, `Peter Edwards` ).
email_contact_lookup( `aeland@ses-ltd.co.uk`, `Andy Eland` ).
email_contact_lookup( `aeland@ses-ltd.co.uk`, `ANDY ELAND` ).
email_contact_lookup( `jfearnley@ses-ltd.co.uk`, `JOANNE FEARNLEY` ).
email_contact_lookup( `dfell@ses-ltd.co.uk`, `DARREN FELL` ).
email_contact_lookup( `lfluin@ses-ltd.co.uk`, `LUKE FLUIN` ).
email_contact_lookup( `mark.forsterspratt@shepley.vhe.co.uk`, `MARK FORSTER-SPRATT` ).
email_contact_lookup( `kbharrison@ses-ltd.co.uk`, `IAN FREEBORN` ).
email_contact_lookup( `rfulford@ses-ltd.co.uk`, `RICHARD FULFORD` ).
email_contact_lookup( `lfulin@ses-ltd.co.uk`, `LUKE FULIN` ).
email_contact_lookup( `mgalley@ses-ltd.co.uk`, `M GALLEY` ).
email_contact_lookup( `jglover@ses-ltd.co.uk`, `JOE GLOVER` ).
email_contact_lookup( `mgray@ses-ltd.co.uk`, `Matthew Gray` ).
email_contact_lookup( `jgriffin@ses-ltd.co.uk`, `JOHN GRIFFIN` ).
email_contact_lookup( `shague@ses-ltd.co.uk`, `Steve Hague` ).
email_contact_lookup( `shague@ses-ltd.co.uk`, `STEVE HAGUE` ).
email_contact_lookup( `thardie@ses-ltd.co.uk`, `TOM HARDIE` ).
email_contact_lookup( `kbharrison@ses-ltd.co.uk`, `KEVIN HARRISON` ).
email_contact_lookup( `ghemsley@shepherd-construction.co.uk`, `GRAHAM HEMSLEY` ).
email_contact_lookup( `thirst@ses-ltd.co.uk`, `Tony Hirst` ).
email_contact_lookup( `thirst@ses-ltd.co.uk`, `TONY HIRST` ).
email_contact_lookup( `rholmes@ses-ltd.co.uk`, `ROBERT HOLMES` ).
email_contact_lookup( `sholt@ses-ltd.co.uk`, `STEPHANIE HOLT` ).
email_contact_lookup( `lhorsfall@ses-ltd.co.uk`, `LIAM HORSFALL` ).
email_contact_lookup( `ngreenwood@ses-ltd.co.uk`, `PAUL HOWARD` ).
email_contact_lookup( `khoy@shepherdbe.com`, `KATIE HOY` ).
email_contact_lookup( `phull@ses=ltd.co.uk`, `Phil Hull` ).
email_contact_lookup( `hworkshop@ses-ltd.co.uk`, `PATRICK IGOE` ).
email_contact_lookup( `dingledew@ses-ltd.co.uk`, `Doug Ingledew` ).
email_contact_lookup( `ajasat@ses-ltd.co.uk`, `AZIM JASAT` ).
email_contact_lookup( `dknott@ses-ltd.co.uk`, `DANNY KNOTT` ).
email_contact_lookup( `nlester@ses-lrd.co.uk`, `NICK LESTER` ).
email_contact_lookup( `clowe@ses-ltd.co.uk`, `CHRISTIAN LOWE` ).
email_contact_lookup( `cmalarkey@ses-ltd.co.uk`, `CAROL MALARKEY` ).
email_contact_lookup( `jackiemann@ses-ltd.co.uk`, `JACKIE MANN` ).
email_contact_lookup( `smann@ses-ltd.co.uk`, `STEVE MANN` ).
email_contact_lookup( `tmarshall-grant@ses-ltd.co.uk`, `Tom Marshall-Grant` ).
email_contact_lookup( `jmayhew@ses-ltd.co.uk`, `JOHN MAYHEW` ).
email_contact_lookup( `cmiles@ses-ltd.co.uk`, `CHRIS MILES` ).
email_contact_lookup( `lmitchell@ses-ltd.co.uk`, `LEE MITCHELL` ).
email_contact_lookup( `tmorgan@ses-ltd.co.uk`, `TOM MORGAN` ).
email_contact_lookup( `smorris2@ses-ltd.co.uk`, `STEPHEN MORRIS` ).
email_contact_lookup( `lo'neill@shepherdbe.com`, `LYNN O'NEIL` ).
email_contact_lookup( `ioates@ses-ltd.co.uk`, `IAN OATES` ).
email_contact_lookup( `clee@ses-ltd.co.uk`, `CARRIE-ANN PEACH` ).
email_contact_lookup( `jpeach@ses-ltd.co.uk`, `JULIE PEACH` ).
email_contact_lookup( `rpendlebury@ses-ltd.co.uk`, `RICHARD PENDLEBURY` ).
email_contact_lookup( `rpendlebury@ses-ltd.co.uk`, `RICHARD PENDLEBURY` ).
email_contact_lookup( `spercival@ses-ltd.co.uk`, `SIMON PERCIVAL` ).
email_contact_lookup( `npeverill@ses-ltd.co.uk`, `NAOMI PEVERILL` ).
email_contact_lookup( `sphillpot@ses-ltd.co.uk`, `SIMON PHILLPOT` ).
email_contact_lookup( `mark.poulton@portakabin.com`, `MARK POULTON` ).
email_contact_lookup( `aratcliffe@ses-ltd.co.uk`, `ALISTAIR RATCLIFFE` ).
email_contact_lookup( `dreeve@ses-ltd.co.uk`, `DAVE REEVE` ).
email_contact_lookup( `drichardson@ses-ltd.co.uk`, `DARREN RICHARDSON` ).
email_contact_lookup( `troberts@ses-ltd.co.uk`, `TERRY ROBERTS` ).
email_contact_lookup( `grobinson@ses-ltd.co.uk`, `GARRICK ROBINSON` ).
email_contact_lookup( `hrodgers@ses-ltd.co.uk`, `HUGH RODGERS` ).
email_contact_lookup( `trogers@ses-ltd.co.uk`, `Tony Rogers` ).
email_contact_lookup( `jshadbolt@ses-ltd.co.uk`, `JIM SHADBOLT` ).
email_contact_lookup( `asharp@ses-ltd.co.uk`, `ANDY SHARPE` ).
email_contact_lookup( `tshaw@ses-ltd.co.uk`, `TOM SHAW` ).
email_contact_lookup( `kshell@ses-ltd.co.uk`, `Kevin Shell` ).
email_contact_lookup( `dshutleworth@ses-ltd.co.uk`, `David Shuttleworth` ).
email_contact_lookup( `tsidwell@ses-ltd.co.uk`, `Tony Sidwell` ).
email_contact_lookup( `jspavin@shepherdbe.com`, `JOANNE SPAVIN` ).
email_contact_lookup( `pstables@ses-ltd.co.uk`, `PAUL STABLES` ).
email_contact_lookup( `ntaylor@ses-ltd.co.uk`, `NEIL TAYLOR` ).
email_contact_lookup( `twillgoose@ses-ltd.co.uk`, `WILLGOOSE TONY` ).
email_contact_lookup( `leonleeu@yahoo.co.uk`, `LEON VROOYEN` ).
email_contact_lookup( `awalker@ses-ltd.co.uk`, `ADY WALKER` ).
email_contact_lookup( `nwharram@ses-ltd.co.uk`, `NEIL WHARRAM` ).
email_contact_lookup( `dwhittaker@ses-ltd.co.uk`, `DARREN WHITTAKER` ).
email_contact_lookup( `pwicks@ses-ltd.co.uk`, `PETE WICKS` ).
email_contact_lookup( `twillgoose@ses-ltd.co.uk`, `TONY WILLGOOSE` ).


%=======================================================================
i_rule( get_buyer_ddi, [
%=======================================================================

	q(0,10,line), generic_horizontal_details( [ [ `All`, `Telephone`, `Enquiries` ] ] )
	
	, q01(line), generic_horizontal_details( [ `(`, buyer_ddi, sf, `)` ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [
%=======================================================================

	q(0,50,line), line_header_line
	, q(0,30,line), delivery_contact_line
	
] ).

%=======================================================================
i_line_rule( delivery_contact_line, [
%=======================================================================

	q0n(word), `contact`
	
	, q0n(word), generic_item( [ delivery_contact, w ] )
	
	, q10( dummy(f( [ q(alpha,1,1) ] ) ) )
	
	, append( delivery_contact(w), ` `, `` )
	
	, or( [ [ read_ahead( dum(d) ), generic_item( [ delivery_ddi, s1, newline ] ) ]
	
		, newline
		
	] )
	
] ).

%=======================================================================
i_rule( get_delivery_ddi, [ without( delivery_ddi ),
%=======================================================================

	q(0,50,line), line_header_line
	
	, q(0,30,line), generic_horizontal_details( [ [ at_start, q0n(word), set( regexp_cross_word_boundaries ) ], delivery_ddi, [ begin, q(dec,11,11), end ] ] )
	
	, clear( regexp_cross_word_boundaries )
	
] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ `P`, `/`, `O`, `Total` ], 400, total_net, d, newline ] )

	, check( total_net = Net )
	
	, total_invoice( Net )
	
	, or( [ [ with( invoice, delivery_charge, Charge )
	
			, check( sys_calculate_str_subtract( total_net, Charge, Net_1 ) )
			
			, net_subtotal_2( Charge )
			
			, gross_subtotal_2( Charge )
			
		]
		
		, [ without( delivery_charge )
		
			, check( total_net = Net_1 )
			
		]
		
	] )
	
	, net_subtotal_1( Net_1 )
	
	, gross_subtotal_1( Net_1 )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, q0n( [

		  or( [ 
		
			  line_invoice_rule

			, line

		] )

	] )

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Our`, `Item`, `number`, `to`, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Delivery`, `Instructions` ]
	
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  read_ahead( line_invoice_line )
	  
	, or( [ gen1_parse_text_rule( [ -460, 160, or( [ line_end_line, line_check_line ] ), line_item, [ begin, q(dec,4,10), end ] ] )
		, [ gen1_parse_text_rule( [ -460, 160, or( [ line_end_line, line_check_line ] ) ] )
			, line_item( `Missing` )
		]
	] )
	
	, check( captured_text = Text )
	, line_descr( Text )

	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_check_line, [ or( [ [ q0n(anything), q(2,2, [ tab, dum(d) ] ), newline ], [ `Any`, `Cables` ] ] ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_item( [ line_order_line_number, w, q10( tab ) ] )

	, generic_item( [ dummy_descr, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )

	, generic_item_cut( [ line_quantity_uom_code, s1, tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )

	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, string_string_replace( Delivery_L, `/`, ` / `, Delivery_Rep )
	, sys_string_split( Delivery_Rep, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage`, `transport` ] )
	, trace( `delivery line, line being ignored` )
.