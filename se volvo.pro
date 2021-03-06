%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - SE VOLVO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( se_volvo, `09 March 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_op_param( o_mail_subject, _, _, _, `WARNING: This document has NOT been processed - ship-to missing` )
:-
	result( _, invoice, force_sub_result, `missing_ship_to` ); data( invoice, force_sub_result, `missing_ship_to` )
.

i_user_field( invoice, delivery_para, `Delivery Paragraph` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_delivery_details
	
	, get_suppliers_code_for_buyer

	, get_buyer_contact

	, get_buyer_email

	, get_order_date

	, get_order_number
	
	, get_invoice_lines

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, [ qn0(line), invoice_total_line]

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

	  without( buyer_party )

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `SE-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2600`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,15,line), generic_vertical_details( [ [ at_start, `Requester` ], buyer_contact, sf, or( [ `(`, gen_eof ] ) ] )
	 
	, check( buyer_contact = Con )
	, delivery_contact( Con )

] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	q(0,15,line), generic_horizontal_details( [ [ at_start, `Email`, `:` ], buyer_email, s1 ] )
	
	, check( buyer_email = Email )
	, delivery_email( Email )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [
%=======================================================================

	qn0(line), generic_vertical_details( [ [ `VAT`, `No` ], buyers_code_for_buyer_x, s1 ] )
	
	, or( [ with( invoice, delivery_para, Para ), check( Para = `` ) ] )
	
	, check( i_user_check( perform_address_lookup, buyers_code_for_buyer_x, Para, DNN, SCFB, Party, Street ) )
	
	, or( [ [ check( DNN = `` )
			, trace( [ `Lookup failed` ] )
			, force_result( `failed` )
			, force_sub_result( `missing_ship_to` )
		]
		
		, [ delivery_note_number( DNN )
			, suppliers_code_for_buyer( SCFB )
			, trace( [ `Lookup Successful`, SCFB ] )
%			, delivery_party( Party )
%			, delivery_street( Street )
		]
	] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ at_start, `Ship`, `To`, `Address` ] ] )

	, gen1_parse_text_rule( [ -500, -51, delivery_postcode_and_city_line ] )
	
	, check( captured_text = Cap )
	, delivery_para( Cap )
	
	, trace( [ `Delivery Para`, delivery_para ] )
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================

	  q10( [ `SE`, `-` ] )
	  
	, generic_item( [ delivery_postcode, [ begin, q(dec,3,3), end ] ] )
	, append( delivery_postcode( f( [ begin, q(dec,2,2), end ] ) ), ` `, `` )
	
	, generic_item( [ delivery_city_x, s1 ] )

] ).

%=======================================================================
i_user_check( perform_address_lookup, VAT, Para, DNN, SCFB, Party, Street )
%=======================================================================
:-
	string_to_upper( Para, ParaU ),
	address_lookup( VAT, DNN, SCFB, Party, Street ),
	
	string_to_upper( Street, StreetU ),
	q_sys_sub_string( ParaU, _, _, Party ),
	q_sys_sub_string( ParaU, _, _, StreetU )
.
	
address_lookup( `SE556000075301`, `18463100`, `18463100`, `*VOLVO POWERTRAIN CORPORATION`, `Volvovägen` ).
address_lookup( `SE556034133001`, `11297817`, `11297817`, `AB VOLVO PENTA`, `Önum` ).
address_lookup( `556034133001`, `11297817`, `11297817`, `AB VOLVO PENTA`, `Önum` ).
address_lookup( `SE556034133001`, `11297819`, `11297817`, `AB VOLVO PENTA VARAFABRIKEN`, `Önum` ).
address_lookup( `556034133001`, `11297819`, `11297817`, `AB VOLVO PENTA VARAFABRIKEN`, `Önum` ).
address_lookup( `SE556029034701`, `11370409`, `11370409`, `VOLVO AERO CORPORATION`, `Flygmotor` ).
address_lookup( `556029034701`, `11370409`, `11370409`, `VOLVO AERO CORPORATION`, `Flygmotor` ).
address_lookup( `SE556058348501`, `11305914`, `11305914`, `VOLVO BUSSAR AB`, `Åmåls` ).
address_lookup( `556058348501`, `11305914`, `11305914`, `VOLVO BUSSAR AB`, `Åmåls` ).
address_lookup( `SE556197382601`, `19080492`, `19080492`, `VOLVO BUSSAR AB`, `` ).
address_lookup( `556197382601`, `19080492`, `19080492`, `VOLVO BUSSAR AB`, `` ).
address_lookup( `SE556540169101`, `17851269`, `17851269`, `VOLVO BUSSAR UDDEVALLA AB`, `Svensebergsvägen` ).
address_lookup( `556540169101`, `17851269`, `17851269`, `VOLVO BUSSAR UDDEVALLA AB`, `Svensebergsvägen` ).
address_lookup( `556540169101`, `17851269`, `17851269`, `Volvo Bussar Uddevalla AB`, `Svensebergsvägen` ).
address_lookup( `SE556074308901`, `14326955`, `14326955`, `VOLVO CAR CORPORATION`, `Bruks` ).
address_lookup( `556074308901`, `14326955`, `14326955`, `VOLVO CAR CORPORATION`, `Bruks` ).
address_lookup( `SE556021933801`, `17973018`, `17972963`, `VOLVO CONSTRUCTION EQUIPMENT AB`, `.` ).
address_lookup( `556021933801`, `17973018`, `17972963`, `VOLVO CONSTRUCTION EQUIPMENT AB`, `.` ).
address_lookup( `SE556021933801`, `11355251`, `11355251`, `VOLVO CONSTRUCTION EQUIPMENT AB`, `Amazon` ).
address_lookup( `556021933801`, `11355251`, `11355251`, `VOLVO CONSTRUCTION EQUIPMENT AB`, `Amazon` ).
address_lookup( `SE556021933801`, `11299802`, `11299802`, `VOLVO CONSTRUCTION EQUIPMENT AB`, `Carl Lihnells` ).
address_lookup( `556021933801`, `11299802`, `11299802`, `VOLVO CONSTRUCTION EQUIPMENT AB`, `Carl Lihnells` ).
address_lookup( `SE556021933801`, `11303209`, `11303209`, `VOLVO CONSTRUCTION EQUIPMENT AB`, `Esplanaden ` ).
address_lookup( `556021933801`, `11303209`, `11303209`, `VOLVO CONSTRUCTION EQUIPMENT AB`, `Esplanaden ` ).
address_lookup( `SE556021933801`, `14788427`, `11313626`, `VOLVO CONSTRUCTION EQUIPMENT AB`, `Styckåsvägen` ).
address_lookup( `556021933801`, `14788427`, `11313626`, `VOLVO CONSTRUCTION EQUIPMENT AB`, `Styckåsvägen` ).
address_lookup( `SE556021933801`, `14788427`, `11313626`, `Volvo Construction Equipment AB`, `Styckåsvägen` ).
address_lookup( `SE556021933801`, `20497948`, `11299802`, `VOLVO CONSTRUCTION EQUIPMENT AB`, `FÖRRÅD` ).
address_lookup( `556021933801`, `20497948`, `11299802`, `VOLVO CONSTRUCTION EQUIPMENT AB`, `FÖRRÅD` ).
address_lookup( `SE556021933801`, `17972963`, `17972963`, `VOLVO CONSTRUCTION EQUIPMENT AB`, `` ).
address_lookup( `556021933801`, `17972963`, `17972963`, `VOLVO CONSTRUCTION EQUIPMENT AB`, `` ).
address_lookup( `SE556013970001`, `21783314`, `11313296`, `Volvo Group Sweden AB Tuve`, `Stenebyvägen` ).
address_lookup( `556013970001`, `21783314`, `11313296`, `Volvo Group Sweden AB Tuve`, `Stenebyvägen` ).
address_lookup( `SE556013970001`, `11313299`, `11313299`, `VOLVO LASTVAGNAR AB`, `Bölevägen` ).
address_lookup( `556013970001`, `11313299`, `11313299`, `VOLVO LASTVAGNAR AB`, `Bölevägen` ).
address_lookup( `SE556013970001`, `11313296`, `11313296`, `VOLVO LASTVAGNAR AB`, `Gropegårds` ).
address_lookup( `556013970001`, `11313296`, `11313296`, `VOLVO LASTVAGNAR AB`, `Gropegårds` ).
address_lookup( `SE556013970001`, `21783314`, `11313296`, `VOLVO LASTVAGNAR AB`, `Stenebyvägen` ).
address_lookup( `E556013970001`, `21783314`, `11313296`, `VOLVO LASTVAGNAR AB`, `Stenebyvägen` ).
address_lookup( `SE556013970001`, `18866611`, `11313296`, `VOLVO LASTVAGNAR AB`, `Stenebyvägen` ).
address_lookup( `556013970001`, `18866611`, `11313296`, `VOLVO LASTVAGNAR AB`, `Stenebyvägen` ).
address_lookup( `SE556197973201`, `19033666`, `19033666`, `VOLVO LOGISTICS AB`, `Bergegård` ).
address_lookup( `556197973201`, `19033666`, `19033666`, `VOLVO LOGISTICS AB`, `Bergegård` ).
address_lookup( `SE556365974601`, `11344685`, `11344685`, `VOLVO PARTS AB`, `Drottning` ).
address_lookup( `556365974601`, `11344685`, `11344685`, `VOLVO PARTS AB`, `Drottning` ).
address_lookup( `SE556365974601`, `11344688`, `11344685`, `VOLVO PARTS AB`, `Varia` ).
address_lookup( `556365974601`, `11344688`, `11344685`, `VOLVO PARTS AB`, `Varia` ).
address_lookup( `SE556074308901`, `11312440`, `11312440`, `VOLVO PERSONBILAR SVERIGE AB`, `50090` ).
address_lookup( `556074308901`, `11312440`, `11312440`, `VOLVO PERSONBILAR SVERIGE AB`, `50090` ).
address_lookup( `SE556000075301`, `11315199`, `11315199`, `VOLVO POWERTRAIN AB`, `Gropegårds` ).
address_lookup( `556000075301`, `11315199`, `11315199`, `VOLVO POWERTRAIN AB`, `Gropegårds` ).
address_lookup( `SE556000075301`, `21293147`, `11315199`, `VOLVO POWERTRAIN AB`, `Jägershill` ).
address_lookup( `556000075301`, `21293147`, `11315199`, `VOLVO POWERTRAIN AB`, `Jägershill` ).
address_lookup( `SE556000075301`, `18463100`, `18463100`, `VOLVO POWERTRAIN AB`, `Volvovägen` ).
address_lookup( `556000075301`, `18463100`, `18463100`, `VOLVO POWERTRAIN AB`, `Volvovägen` ).
address_lookup( `SE556000075301`, `18463100`, `18463100`, `Volvo Powertrain Corporation`, `Volvovägen` ).
address_lookup( `SE556542432101`, `22163161`, `11478443`, `Volvo Technology AB`, `Chalmers Teknik` ).
address_lookup( `SE556542432101`, `11478443`, `11478443`, `VOLVO TECHNOLOGY AB`, `Fästning` ).
address_lookup( `556542432101`, `11478443`, `11478443`, `VOLVO TECHNOLOGY AB`, `Fästning` ).
address_lookup( `SE556542432101`, `22163161`, `11478443`, `VOLVO TECHNOLOGY AB`, `HULTINSGATA` ).
address_lookup( `SE556072777701`, `11339826`, `11339826`, `VOLVO TRUCK CENTER SWEDEN AB`, `Knista` ).
address_lookup( `556072777701`, `11339826`, `11339826`, `VOLVO TRUCK CENTER SWEDEN AB`, `Knista` ).
address_lookup( `SE556013970001`, `11315423`, `11315423`, `VOLVO TRUCK CORPORATION AB`, `Gropegårds` ).
address_lookup( `556013970001`, `11315423`, `11315423`, `VOLVO TRUCK CORPORATION AB`, `Gropegårds` ).




address_lookup( _, ``, ``, ``, `` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ at_start, `Purchase`, `Order`, `:` ], order_number, s1 ] )

] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Order`, `Date`, `:` ], invoice_date, date ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	  `Grand`, `total`, `net`, `:`, q01( tab )

	, read_ahead(total_invoice(d))

	, total_net(d)

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

		, or( [ line_invoice_rule
		
			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Measure`, tab, `price`] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Grand`, `total` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
	
	, generic_item_cut( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item_cut( [ line_unit_amount_x, d ] )
	
	, q10( [ without( delivery_date ), read_ahead( generic_item( [ delivery_date, date ] ) ) ] )
	
	, generic_item( [ line_original_order_date, date, tab ] )

	, generic_item_cut( [ line_net_amount, d ] )
	
	, word, newline

] ).

