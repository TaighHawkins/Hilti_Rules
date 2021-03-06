%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DK ATEA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( dk_atea, `4 December 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_capture( [ `Købsordre`, order_number, s1, newline ] )
	
	, get_order_date

	, get_delivery_details
	
	, get_buyers_code_for_buyer
	
	, gen_capture( [ `Indkøber`, 200, buyer_contact, s1 ] )
	, gen_capture( [ `Indkøber`, 200, delivery_contact, s1 ] )
	
	, gen_capture( [ [ `I`, `alt`, `DKK`, `ekskl`, `.`, `moms` ], 200, total_net, d, newline ] )
	, gen_capture( [ [ `I`, `alt`, `DKK`, `ekskl`, `.`, `moms` ], 200, total_invoice, d, newline ] )
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, gen_section( [ line_invoice_line ] )
	
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

	, buyer_registration_number( `DK-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2700`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, set( reverse_punctuation_in_numbers )
	
	, delivery_party(`Atea A/S`)
	
	, sender_name(`Atea A/S`)

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	q0n(line), generic_horizontal_details( [ `Dato`, invoice_date_x, s1, newline ] )

	, check( i_user_check( danish_month_change, invoice_date_x, Date ) )
	
	, invoice_date(Date)
	
	, trace( [ `Invoice Date`, Date ] )
	
] ).

%=======================================================================
i_user_check( danish_month_change, Date_In, Date_Out )
%=======================================================================
:-
	string_to_lower( Date_In, Date_L ),
	strip_string2_from_string1( Date_L, `.`, Date_Strip ),
	sys_string_split( Date_Strip, ` `, [ Day, Month, Year ] ),
	date_lookup( Month, Number ),
	sys_stringlist_concat( [ Day, Number, Year ], `/`, Date_Out )
.

date_lookup( `januar`, `01` ).
date_lookup( `jan`, `01` ).
date_lookup( `februar`, `02` ).
date_lookup( `feb`, `02` ).
date_lookup( `marts`, `03` ).
date_lookup( `mar`, `03` ).
date_lookup( `april`, `04` ).
date_lookup( `apr`, `04` ).
date_lookup( `kan`, `05` ).
date_lookup( `maj`, `05` ).
date_lookup( `juni`, `06` ).
date_lookup( `jun`, `06` ).
date_lookup( `juli`, `07` ).
date_lookup( `jul`, `07` ).
date_lookup( `august`, `08` ).
date_lookup( `aug`, `08` ).
date_lookup( `september`, `09` ).
date_lookup( `sep`, `09` ).
date_lookup( `oktober`, `10` ).
date_lookup( `okt`, `10` ).
date_lookup( `november`, `11` ).
date_lookup( `nov`, `11` ).
date_lookup( `december`, `12` ).
date_lookup( `dec`, `12` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_thing( [ Var ] ), [ nearest( generic_hook(start), 10, 10 ), generic_item( [ Var, s1 ] ) ] ).
%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, `Leveringsadresse` ] ] )
	
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
	
	, delivery_thing( [ delivery_dept ] )
	
	, q10( generic_line( [ [ `Atea`, `A`, `/`, `S` ] ] ) )
	
	, delivery_thing( [ delivery_address_line ] )
	
	, q10( delivery_thing( [ delivery_address_line ] ) )
	
	, q10( generic_line( [ [ `Atea`, `A`, `/`, `S` ] ] ) )
	
	, delivery_thing( [ delivery_street ] )
	
	, delivery_postcode_city_line
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================

	  nearest( generic_hook(start), 10, 10 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( get_buyers_code_for_buyer, [
%=======================================================================

	generic_line( [ [ `Atea`, `A`, `/`, `S` ] ] )
	
	, buyers_code_for_buyer_line
	
] ).

%=======================================================================
i_line_rule_cut( buyers_code_for_buyer_line, [
%=======================================================================

	q0n(word)
	
	, num(d), `-`, trace( [ `num`, num ] )
	
	, wrap( buyers_code_for_buyer(f([ begin, q(dec,4,4), end ])), `DKATEA`, `` )
	
	, check( num = Num ), append( buyers_code_for_buyer(Num), `-`, `` )
	
	, trace( [ `buyers_code_for_buyer`, buyers_code_for_buyer ] )
	
	, q0n(word), newline
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GEN SECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`Nummer`, tab, `Beskrivelse`, tab

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`I`, `alt`, `DKK`
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	line_item_for_buyer(s1), tab
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, line_quantity(d), tab
	
	, q10( [ line_quantity_uom_code(w), tab ] )
	
	, line_unit_amount(d), tab
	
	, generic_item( [ line_net_amount, d, newline ] )
	
	, count_rule

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )

	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).