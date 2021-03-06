%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US CAPFORM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_capform, `17 August 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).
i_user_field( invoice, delivery_location_x, `Delivery Location Raw` ).

i_user_field( line, additional_item_code, `Extra item` ).
bespoke_e1edp19_segment( [ `098`, additional_item_code ] ).

%=======================================================================
%		User Fields
%=======================================================================

i_user_field( line, zzfmcontracttype, `ZZF contracttype` ).

%=======================================================================
%		Empty Tags
%=======================================================================

i_op_param( xml_empty_tags( `AUTLF` ), _, _, _, X ) :- result( _, invoice, autlf, X ).

i_op_param( xml_empty_tags( Fleet_U ), _, _, _, _, Answer )
:-
	  line_lid_being_written( LID )
	, fleet_thing( Fleet )
	, sys_string_atom( Fleet, Atom )
	, result( _, LID, Atom, Answer )
	, string_to_upper( Fleet, Fleet_U )
.

fleet_thing( `zzfminvnr` ).
fleet_thing( `zzfmorgref` ).
fleet_thing( `zzfmcontracttype` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_delivery_details
	
	, get_order_number
	, get_order_date

	, get_totals

	, get_buyer_dept
	, get_delivery_from_contact
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

] ):- not( grammar_set( do_not_process ) ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `US-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `11266131` ) ]
		, suppliers_code_for_buyer( `10748052` )
	] )

	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Capform Inc.` )
	, delivery_party( `CAPFORM INC` )
	
	, check( i_user_check( check_submission_time, Flag ) )
	, set( Flag )
	
] ).

%=======================================================================
i_user_check( check_submission_time, Flag )
%-----------------------------------------------------------------------
:- 
	i_mail( time_stamp, TS ),
	sys_string_split( TS, `.`, [ Year, Month, Day, Hour | _ ] ),
	( q_sys_comp_str_lt( Hour, `16` )
		->	Flag = before
		
		;	Hour = `16`,
			q_sys_comp_str_lt( Min, `45` )
				
		;	Flag = after
	),
	trace( [ `Order was submitted `, Flag, ` 11am cutoff` ] )
.
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,30,line)  
	
	, generic_horizontal_details( [ [ `Site`, `Name` ], delivery_dept, s1 ] )
	
	, generic_horizontal_details( [ [ `Site`, `Address` ], delivery_street, s1 ] )

	, q01(line)
	, generic_line( [ [ 
		q0n(anything)
		, `City`, `,`, `State`, `Zip`
		, delivery_city(sf), `,`, delivery_state(w), delivery_postcode( f( [ begin, q(dec,5,5), end ] ) )
		, trace( [ `City, State, Zip`, delivery_city, delivery_state, delivery_postcode ] )
	] ] )
	
	, or( [ [ check( i_user_check( check_zip_is_in_lookup, delivery_postcode ) )
			
			, or( [ [ test( before )
					, trace( [ `Before cutoff` ] )
					, type_of_supply( `NM` )
					, cost_centre( `Jobsite_FourHours` )
				]
				, [ test( after )
					, trace( [ `After Cutoff` ] )
					, type_of_supply( `NN` )
					, cost_centre( `HNA:JOBSITE_NEXT_AM` )
				]
			] )
		]
		
		, [ type_of_supply( `01` )
			, cost_centre( `Standard` )
			, trace( [ `Default Values` ] )
		]
	] )
	, trace( [ `ToS and CC`, type_of_supply, cost_centre ] )
] ).

%=======================================================================
i_user_check( check_zip_is_in_lookup, Zip )
%-----------------------------------------------------------------------
:- zipcode_shipping_check( Zip ), trace( [ `Zip in table` ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER & DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,10,line), generic_vertical_details( [ [ `Purchase`, `Order` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  qn0(line), generic_horizontal_details( [ [ `Date`, `Created` ], invoice_date, date ] )
	
] ).

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_dept, [ 
%=======================================================================

	  buyer_dept( BD )
	, trace( [ `Buyer Dept`, BD ] )

] )
:- 
	i_mail( from, From ), 
	sys_string_split( From, `@`, [ Names | _ ] ),
	string_to_upper( Names, NamesU ),
	sys_string_length( NamesU, NamesLen ),
	
	( NamesLen < 12
		->	NamesU = Value
		
		;	q_sys_sub_string( NamesU, 1, 11, Value )
	),
	strcat_list( [ `USCAPF`, Value ], BD )
.

%=======================================================================
i_rule( get_delivery_from_contact, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Site`, `#` ], delivery_from_contact, s1 ] )
	  
	, prepend( delivery_from_contact( `USCAPF` ), ``, `` )
	
] ).

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  qn0(line)
	  
	, generic_vertical_details( [ [ or( [ at_start, tab ] ), `Sub`, `-`, `Total` ], `Total`, total_net, d, newline ] )

	, check( total_net = Net )
	, total_invoice( Net )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [  line_invoice_rule
		  
			, generic_line( [ [ append( line_descr(s1), ` `, `` ), newline ] ] )
		
			, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ read_ahead( [ `Code`, tab, `Price` ] ), header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ [ `PO`, `Totals` ]
	
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

	, count_rule
	
	, q10( [ check( line_item = `273758` )
		, zzfmcontracttype( `ZFCL` )
	] )

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
	
	generic_item_cut( [ item, d ] )
	
	, generic_item_cut( [ cost_code, d, q10( tab ) ] )

	, generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	, check( line_item = Item )
	, additional_item_code( Item )
	
	, generic_item_cut( [ line_descr, s1, tab ] )
	
	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )

	, generic_item_cut( [ line_net_amount, d, newline ] )
	
	, line_quantity_uom_code( `PC` )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

zipcode_shipping_check( `75001` ).
zipcode_shipping_check( `75002` ).
zipcode_shipping_check( `75006` ).
zipcode_shipping_check( `75007` ).
zipcode_shipping_check( `75009` ).
zipcode_shipping_check( `75010` ).
zipcode_shipping_check( `75011` ).
zipcode_shipping_check( `75013` ).
zipcode_shipping_check( `75014` ).
zipcode_shipping_check( `75015` ).
zipcode_shipping_check( `75016` ).
zipcode_shipping_check( `75017` ).
zipcode_shipping_check( `75019` ).
zipcode_shipping_check( `75022` ).
zipcode_shipping_check( `75023` ).
zipcode_shipping_check( `75024` ).
zipcode_shipping_check( `75025` ).
zipcode_shipping_check( `75026` ).
zipcode_shipping_check( `75027` ).
zipcode_shipping_check( `75028` ).
zipcode_shipping_check( `75029` ).
zipcode_shipping_check( `75030` ).
zipcode_shipping_check( `75032` ).
zipcode_shipping_check( `75033` ).
zipcode_shipping_check( `75034` ).
zipcode_shipping_check( `75035` ).
zipcode_shipping_check( `75038` ).
zipcode_shipping_check( `75039` ).
zipcode_shipping_check( `75040` ).
zipcode_shipping_check( `75041` ).
zipcode_shipping_check( `75042` ).
zipcode_shipping_check( `75043` ).
zipcode_shipping_check( `75044` ).
zipcode_shipping_check( `75045` ).
zipcode_shipping_check( `75046` ).
zipcode_shipping_check( `75047` ).
zipcode_shipping_check( `75048` ).
zipcode_shipping_check( `75049` ).
zipcode_shipping_check( `75050` ).
zipcode_shipping_check( `75051` ).
zipcode_shipping_check( `75052` ).
zipcode_shipping_check( `75053` ).
zipcode_shipping_check( `75054` ).
zipcode_shipping_check( `75056` ).
zipcode_shipping_check( `75057` ).
zipcode_shipping_check( `75060` ).
zipcode_shipping_check( `75061` ).
zipcode_shipping_check( `75062` ).
zipcode_shipping_check( `75063` ).
zipcode_shipping_check( `75064` ).
zipcode_shipping_check( `75067` ).
zipcode_shipping_check( `75068` ).
zipcode_shipping_check( `75070` ).
zipcode_shipping_check( `75071` ).
zipcode_shipping_check( `75074` ).
zipcode_shipping_check( `75075` ).
zipcode_shipping_check( `75077` ).
zipcode_shipping_check( `75078` ).
zipcode_shipping_check( `75080` ).
zipcode_shipping_check( `75081` ).
zipcode_shipping_check( `75082` ).
zipcode_shipping_check( `75083` ).
zipcode_shipping_check( `75085` ).
zipcode_shipping_check( `75086` ).
zipcode_shipping_check( `75087` ).
zipcode_shipping_check( `75088` ).
zipcode_shipping_check( `75089` ).
zipcode_shipping_check( `75093` ).
zipcode_shipping_check( `75094` ).
zipcode_shipping_check( `75097` ).
zipcode_shipping_check( `75098` ).
zipcode_shipping_check( `75099` ).
zipcode_shipping_check( `75104` ).
zipcode_shipping_check( `75106` ).
zipcode_shipping_check( `75115` ).
zipcode_shipping_check( `75116` ).
zipcode_shipping_check( `75121` ).
zipcode_shipping_check( `75123` ).
zipcode_shipping_check( `75125` ).
zipcode_shipping_check( `75126` ).
zipcode_shipping_check( `75132` ).
zipcode_shipping_check( `75134` ).
zipcode_shipping_check( `75137` ).
zipcode_shipping_check( `75138` ).
zipcode_shipping_check( `75141` ).
zipcode_shipping_check( `75146` ).
zipcode_shipping_check( `75149` ).
zipcode_shipping_check( `75150` ).
zipcode_shipping_check( `75154` ).
zipcode_shipping_check( `75159` ).
zipcode_shipping_check( `75164` ).
zipcode_shipping_check( `75166` ).
zipcode_shipping_check( `75172` ).
zipcode_shipping_check( `75173` ).
zipcode_shipping_check( `75180` ).
zipcode_shipping_check( `75181` ).
zipcode_shipping_check( `75182` ).
zipcode_shipping_check( `75185` ).
zipcode_shipping_check( `75187` ).
zipcode_shipping_check( `75189` ).
zipcode_shipping_check( `75201` ).
zipcode_shipping_check( `75202` ).
zipcode_shipping_check( `75203` ).
zipcode_shipping_check( `75204` ).
zipcode_shipping_check( `75205` ).
zipcode_shipping_check( `75206` ).
zipcode_shipping_check( `75207` ).
zipcode_shipping_check( `75208` ).
zipcode_shipping_check( `75209` ).
zipcode_shipping_check( `75210` ).
zipcode_shipping_check( `75211` ).
zipcode_shipping_check( `75212` ).
zipcode_shipping_check( `75214` ).
zipcode_shipping_check( `75215` ).
zipcode_shipping_check( `75216` ).
zipcode_shipping_check( `75217` ).
zipcode_shipping_check( `75218` ).
zipcode_shipping_check( `75219` ).
zipcode_shipping_check( `75220` ).
zipcode_shipping_check( `75221` ).
zipcode_shipping_check( `75222` ).
zipcode_shipping_check( `75223` ).
zipcode_shipping_check( `75224` ).
zipcode_shipping_check( `75225` ).
zipcode_shipping_check( `75226` ).
zipcode_shipping_check( `75227` ).
zipcode_shipping_check( `75228` ).
zipcode_shipping_check( `75229` ).
zipcode_shipping_check( `75230` ).
zipcode_shipping_check( `75231` ).
zipcode_shipping_check( `75232` ).
zipcode_shipping_check( `75233` ).
zipcode_shipping_check( `75234` ).
zipcode_shipping_check( `75235` ).
zipcode_shipping_check( `75236` ).
zipcode_shipping_check( `75237` ).
zipcode_shipping_check( `75238` ).
zipcode_shipping_check( `75240` ).
zipcode_shipping_check( `75241` ).
zipcode_shipping_check( `75242` ).
zipcode_shipping_check( `75243` ).
zipcode_shipping_check( `75244` ).
zipcode_shipping_check( `75246` ).
zipcode_shipping_check( `75247` ).
zipcode_shipping_check( `75248` ).
zipcode_shipping_check( `75249` ).
zipcode_shipping_check( `75250` ).
zipcode_shipping_check( `75251` ).
zipcode_shipping_check( `75252` ).
zipcode_shipping_check( `75253` ).
zipcode_shipping_check( `75254` ).
zipcode_shipping_check( `75260` ).
zipcode_shipping_check( `75261` ).
zipcode_shipping_check( `75262` ).
zipcode_shipping_check( `75263` ).
zipcode_shipping_check( `75264` ).
zipcode_shipping_check( `75265` ).
zipcode_shipping_check( `75266` ).
zipcode_shipping_check( `75267` ).
zipcode_shipping_check( `75270` ).
zipcode_shipping_check( `75275` ).
zipcode_shipping_check( `75277` ).
zipcode_shipping_check( `75283` ).
zipcode_shipping_check( `75284` ).
zipcode_shipping_check( `75285` ).
zipcode_shipping_check( `75287` ).
zipcode_shipping_check( `75301` ).
zipcode_shipping_check( `75303` ).
zipcode_shipping_check( `75312` ).
zipcode_shipping_check( `75313` ).
zipcode_shipping_check( `75315` ).
zipcode_shipping_check( `75320` ).
zipcode_shipping_check( `75326` ).
zipcode_shipping_check( `75336` ).
zipcode_shipping_check( `75339` ).
zipcode_shipping_check( `75342` ).
zipcode_shipping_check( `75354` ).
zipcode_shipping_check( `75355` ).
zipcode_shipping_check( `75356` ).
zipcode_shipping_check( `75357` ).
zipcode_shipping_check( `75358` ).
zipcode_shipping_check( `75359` ).
zipcode_shipping_check( `75360` ).
zipcode_shipping_check( `75367` ).
zipcode_shipping_check( `75368` ).
zipcode_shipping_check( `75370` ).
zipcode_shipping_check( `75371` ).
zipcode_shipping_check( `75372` ).
zipcode_shipping_check( `75373` ).
zipcode_shipping_check( `75374` ).
zipcode_shipping_check( `75376` ).
zipcode_shipping_check( `75378` ).
zipcode_shipping_check( `75379` ).
zipcode_shipping_check( `75380` ).
zipcode_shipping_check( `75381` ).
zipcode_shipping_check( `75382` ).
zipcode_shipping_check( `75389` ).
zipcode_shipping_check( `75390` ).
zipcode_shipping_check( `75391` ).
zipcode_shipping_check( `75392` ).
zipcode_shipping_check( `75393` ).
zipcode_shipping_check( `75394` ).
zipcode_shipping_check( `75395` ).
zipcode_shipping_check( `75397` ).
zipcode_shipping_check( `75398` ).
zipcode_shipping_check( `75407` ).
zipcode_shipping_check( `75409` ).
zipcode_shipping_check( `75424` ).
zipcode_shipping_check( `75442` ).
zipcode_shipping_check( `75452` ).
zipcode_shipping_check( `75454` ).
zipcode_shipping_check( `75485` ).
zipcode_shipping_check( `76001` ).
zipcode_shipping_check( `76002` ).
zipcode_shipping_check( `76003` ).
zipcode_shipping_check( `76004` ).
zipcode_shipping_check( `76005` ).
zipcode_shipping_check( `76006` ).
zipcode_shipping_check( `76007` ).
zipcode_shipping_check( `76008` ).
zipcode_shipping_check( `76010` ).
zipcode_shipping_check( `76011` ).
zipcode_shipping_check( `76012` ).
zipcode_shipping_check( `76013` ).
zipcode_shipping_check( `76014` ).
zipcode_shipping_check( `76015` ).
zipcode_shipping_check( `76016` ).
zipcode_shipping_check( `76017` ).
zipcode_shipping_check( `76018` ).
zipcode_shipping_check( `76019` ).
zipcode_shipping_check( `76020` ).
zipcode_shipping_check( `76021` ).
zipcode_shipping_check( `76022` ).
zipcode_shipping_check( `76028` ).
zipcode_shipping_check( `76034` ).
zipcode_shipping_check( `76036` ).
zipcode_shipping_check( `76037` ).
zipcode_shipping_check( `76040` ).
zipcode_shipping_check( `76051` ).
zipcode_shipping_check( `76052` ).
zipcode_shipping_check( `76053` ).
zipcode_shipping_check( `76054` ).
zipcode_shipping_check( `76060` ).
zipcode_shipping_check( `76063` ).
zipcode_shipping_check( `76071` ).
zipcode_shipping_check( `76078` ).
zipcode_shipping_check( `76092` ).
zipcode_shipping_check( `76094` ).
zipcode_shipping_check( `76095` ).
zipcode_shipping_check( `76096` ).
zipcode_shipping_check( `76099` ).
zipcode_shipping_check( `76101` ).
zipcode_shipping_check( `76102` ).
zipcode_shipping_check( `76103` ).
zipcode_shipping_check( `76104` ).
zipcode_shipping_check( `76105` ).
zipcode_shipping_check( `76106` ).
zipcode_shipping_check( `76107` ).
zipcode_shipping_check( `76108` ).
zipcode_shipping_check( `76109` ).
zipcode_shipping_check( `76110` ).
zipcode_shipping_check( `76111` ).
zipcode_shipping_check( `76112` ).
zipcode_shipping_check( `76113` ).
zipcode_shipping_check( `76114` ).
zipcode_shipping_check( `76115` ).
zipcode_shipping_check( `76116` ).
zipcode_shipping_check( `76117` ).
zipcode_shipping_check( `76118` ).
zipcode_shipping_check( `76119` ).
zipcode_shipping_check( `76120` ).
zipcode_shipping_check( `76121` ).
zipcode_shipping_check( `76122` ).
zipcode_shipping_check( `76123` ).
zipcode_shipping_check( `76124` ).
zipcode_shipping_check( `76126` ).
zipcode_shipping_check( `76127` ).
zipcode_shipping_check( `76129` ).
zipcode_shipping_check( `76130` ).
zipcode_shipping_check( `76131` ).
zipcode_shipping_check( `76132` ).
zipcode_shipping_check( `76133` ).
zipcode_shipping_check( `76134` ).
zipcode_shipping_check( `76135` ).
zipcode_shipping_check( `76136` ).
zipcode_shipping_check( `76137` ).
zipcode_shipping_check( `76140` ).
zipcode_shipping_check( `76147` ).
zipcode_shipping_check( `76148` ).
zipcode_shipping_check( `76150` ).
zipcode_shipping_check( `76155` ).
zipcode_shipping_check( `76161` ).
zipcode_shipping_check( `76162` ).
zipcode_shipping_check( `76163` ).
zipcode_shipping_check( `76164` ).
zipcode_shipping_check( `76166` ).
zipcode_shipping_check( `76177` ).
zipcode_shipping_check( `76179` ).
zipcode_shipping_check( `76180` ).
zipcode_shipping_check( `76181` ).
zipcode_shipping_check( `76182` ).
zipcode_shipping_check( `76185` ).
zipcode_shipping_check( `76191` ).
zipcode_shipping_check( `76192` ).
zipcode_shipping_check( `76193` ).
zipcode_shipping_check( `76196` ).
zipcode_shipping_check( `76197` ).
zipcode_shipping_check( `76198` ).
zipcode_shipping_check( `76199` ).
zipcode_shipping_check( `76201` ).
zipcode_shipping_check( `76202` ).
zipcode_shipping_check( `76203` ).
zipcode_shipping_check( `76204` ).
zipcode_shipping_check( `76205` ).
zipcode_shipping_check( `76206` ).
zipcode_shipping_check( `76207` ).
zipcode_shipping_check( `76208` ).
zipcode_shipping_check( `76209` ).
zipcode_shipping_check( `76210` ).
zipcode_shipping_check( `76226` ).
zipcode_shipping_check( `76227` ).
zipcode_shipping_check( `76244` ).
zipcode_shipping_check( `76247` ).
zipcode_shipping_check( `76248` ).
zipcode_shipping_check( `76249` ).
zipcode_shipping_check( `76258` ).
zipcode_shipping_check( `76259` ).
zipcode_shipping_check( `76262` ).
zipcode_shipping_check( `76266` ).
zipcode_shipping_check( `76272` ).
zipcode_shipping_check( `79195` ).
zipcode_shipping_check( `76530` ).
zipcode_shipping_check( `76574` ).
zipcode_shipping_check( `76578` ).
zipcode_shipping_check( `78602` ).
zipcode_shipping_check( `78610` ).
zipcode_shipping_check( `78612` ).
zipcode_shipping_check( `78613` ).
zipcode_shipping_check( `78615` ).
zipcode_shipping_check( `78617` ).
zipcode_shipping_check( `78621` ).
zipcode_shipping_check( `78626` ).
zipcode_shipping_check( `78628` ).
zipcode_shipping_check( `78633` ).
zipcode_shipping_check( `78634` ).
zipcode_shipping_check( `78640` ).
zipcode_shipping_check( `78641` ).
zipcode_shipping_check( `78642` ).
zipcode_shipping_check( `78645` ).
zipcode_shipping_check( `78650` ).
zipcode_shipping_check( `78652` ).
zipcode_shipping_check( `78653` ).
zipcode_shipping_check( `78660` ).
zipcode_shipping_check( `78664` ).
zipcode_shipping_check( `78665` ).
zipcode_shipping_check( `78669` ).
zipcode_shipping_check( `78681` ).
zipcode_shipping_check( `78701` ).
zipcode_shipping_check( `78702` ).
zipcode_shipping_check( `78703` ).
zipcode_shipping_check( `78704` ).
zipcode_shipping_check( `78705` ).
zipcode_shipping_check( `78712` ).
zipcode_shipping_check( `78717` ).
zipcode_shipping_check( `78719` ).
zipcode_shipping_check( `78721` ).
zipcode_shipping_check( `78722` ).
zipcode_shipping_check( `78723` ).
zipcode_shipping_check( `78724` ).
zipcode_shipping_check( `78725` ).
zipcode_shipping_check( `78726` ).
zipcode_shipping_check( `78727` ).
zipcode_shipping_check( `78728` ).
zipcode_shipping_check( `78729` ).
zipcode_shipping_check( `78730` ).
zipcode_shipping_check( `78731` ).
zipcode_shipping_check( `78732` ).
zipcode_shipping_check( `78733` ).
zipcode_shipping_check( `78734` ).
zipcode_shipping_check( `78735` ).
zipcode_shipping_check( `78736` ).
zipcode_shipping_check( `78737` ).
zipcode_shipping_check( `78738` ).
zipcode_shipping_check( `78739` ).
zipcode_shipping_check( `78741` ).
zipcode_shipping_check( `78742` ).
zipcode_shipping_check( `78744` ).
zipcode_shipping_check( `78745` ).
zipcode_shipping_check( `78746` ).
zipcode_shipping_check( `78747` ).
zipcode_shipping_check( `78748` ).
zipcode_shipping_check( `78749` ).
zipcode_shipping_check( `78750` ).
zipcode_shipping_check( `78751` ).
zipcode_shipping_check( `78752` ).
zipcode_shipping_check( `78753` ).
zipcode_shipping_check( `78754` ).
zipcode_shipping_check( `78756` ).
zipcode_shipping_check( `78757` ).
zipcode_shipping_check( `78758` ).
zipcode_shipping_check( `78759` ).
zipcode_shipping_check( `77002` ).
zipcode_shipping_check( `77003` ).
zipcode_shipping_check( `77004` ).
zipcode_shipping_check( `77005` ).
zipcode_shipping_check( `77006` ).
zipcode_shipping_check( `77007` ).
zipcode_shipping_check( `77008` ).
zipcode_shipping_check( `77009` ).
zipcode_shipping_check( `77010` ).
zipcode_shipping_check( `77011` ).
zipcode_shipping_check( `77012` ).
zipcode_shipping_check( `77013` ).
zipcode_shipping_check( `77014` ).
zipcode_shipping_check( `77015` ).
zipcode_shipping_check( `77016` ).
zipcode_shipping_check( `77017` ).
zipcode_shipping_check( `77018` ).
zipcode_shipping_check( `77019` ).
zipcode_shipping_check( `77020` ).
zipcode_shipping_check( `77021` ).
zipcode_shipping_check( `77022` ).
zipcode_shipping_check( `77023` ).
zipcode_shipping_check( `77024` ).
zipcode_shipping_check( `77025` ).
zipcode_shipping_check( `77026` ).
zipcode_shipping_check( `77027` ).
zipcode_shipping_check( `77028` ).
zipcode_shipping_check( `77029` ).
zipcode_shipping_check( `77030` ).
zipcode_shipping_check( `77031` ).
zipcode_shipping_check( `77032` ).
zipcode_shipping_check( `77033` ).
zipcode_shipping_check( `77034` ).
zipcode_shipping_check( `77035` ).
zipcode_shipping_check( `77036` ).
zipcode_shipping_check( `77037` ).
zipcode_shipping_check( `77038` ).
zipcode_shipping_check( `77039` ).
zipcode_shipping_check( `77040` ).
zipcode_shipping_check( `77041` ).
zipcode_shipping_check( `77042` ).
zipcode_shipping_check( `77043` ).
zipcode_shipping_check( `77044` ).
zipcode_shipping_check( `77045` ).
zipcode_shipping_check( `77046` ).
zipcode_shipping_check( `77047` ).
zipcode_shipping_check( `77048` ).
zipcode_shipping_check( `77049` ).
zipcode_shipping_check( `77050` ).
zipcode_shipping_check( `77051` ).
zipcode_shipping_check( `77053` ).
zipcode_shipping_check( `77054` ).
zipcode_shipping_check( `77055` ).
zipcode_shipping_check( `77056` ).
zipcode_shipping_check( `77057` ).
zipcode_shipping_check( `77058` ).
zipcode_shipping_check( `77059` ).
zipcode_shipping_check( `77060` ).
zipcode_shipping_check( `77061` ).
zipcode_shipping_check( `77062` ).
zipcode_shipping_check( `77063` ).
zipcode_shipping_check( `77064` ).
zipcode_shipping_check( `77065` ).
zipcode_shipping_check( `77066` ).
zipcode_shipping_check( `77067` ).
zipcode_shipping_check( `77068` ).
zipcode_shipping_check( `77069` ).
zipcode_shipping_check( `77070` ).
zipcode_shipping_check( `77071` ).
zipcode_shipping_check( `77072` ).
zipcode_shipping_check( `77073` ).
zipcode_shipping_check( `77074` ).
zipcode_shipping_check( `77075` ).
zipcode_shipping_check( `77076` ).
zipcode_shipping_check( `77077` ).
zipcode_shipping_check( `77078` ).
zipcode_shipping_check( `77079` ).
zipcode_shipping_check( `77080` ).
zipcode_shipping_check( `77081` ).
zipcode_shipping_check( `77082` ).
zipcode_shipping_check( `77083` ).
zipcode_shipping_check( `77084` ).
zipcode_shipping_check( `77085` ).
zipcode_shipping_check( `77086` ).
zipcode_shipping_check( `77087` ).
zipcode_shipping_check( `77088` ).
zipcode_shipping_check( `77089` ).
zipcode_shipping_check( `77090` ).
zipcode_shipping_check( `77091` ).
zipcode_shipping_check( `77092` ).
zipcode_shipping_check( `77093` ).
zipcode_shipping_check( `77094` ).
zipcode_shipping_check( `77095` ).
zipcode_shipping_check( `77096` ).
zipcode_shipping_check( `77098` ).
zipcode_shipping_check( `77099` ).
zipcode_shipping_check( `77338` ).
zipcode_shipping_check( `77339` ).
zipcode_shipping_check( `77345` ).
zipcode_shipping_check( `77346` ).
zipcode_shipping_check( `77365` ).
zipcode_shipping_check( `77373` ).
zipcode_shipping_check( `77375` ).
zipcode_shipping_check( `77377` ).
zipcode_shipping_check( `77379` ).
zipcode_shipping_check( `77380` ).
zipcode_shipping_check( `77381` ).
zipcode_shipping_check( `77385` ).
zipcode_shipping_check( `77386` ).
zipcode_shipping_check( `77388` ).
zipcode_shipping_check( `77389` ).
zipcode_shipping_check( `77396` ).
zipcode_shipping_check( `77401` ).
zipcode_shipping_check( `77429` ).
zipcode_shipping_check( `77433` ).
zipcode_shipping_check( `77449` ).
zipcode_shipping_check( `77450` ).
zipcode_shipping_check( `77477` ).
zipcode_shipping_check( `77478` ).
zipcode_shipping_check( `77489` ).
zipcode_shipping_check( `77493` ).
zipcode_shipping_check( `77494` ).
zipcode_shipping_check( `77501` ).
zipcode_shipping_check( `77502` ).
zipcode_shipping_check( `77503` ).
zipcode_shipping_check( `77504` ).
zipcode_shipping_check( `77505` ).
zipcode_shipping_check( `77506` ).
zipcode_shipping_check( `77507` ).
zipcode_shipping_check( `77530` ).
zipcode_shipping_check( `77536` ).
zipcode_shipping_check( `77545` ).
zipcode_shipping_check( `77546` ).
zipcode_shipping_check( `77547` ).
zipcode_shipping_check( `77571` ).
zipcode_shipping_check( `77573` ).
zipcode_shipping_check( `77581` ).
zipcode_shipping_check( `77584` ).
zipcode_shipping_check( `77586` ).
zipcode_shipping_check( `77587` ).
zipcode_shipping_check( `77598` ).