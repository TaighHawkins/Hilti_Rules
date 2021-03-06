%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US DWP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_dwp, `15 July 2015` ).

i_date_format( `m/d/y` ).

i_format_postcode( X, X ).

i_user_field( invoice, delivery_id, `Delivery ID` ).
i_user_field( invoice, custom_notification_address, `Custom Email Address` ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

i_op_param( custom_e1edk02_segments, _, _, _, `true` ).
i_user_field( invoice, quotation_number, `Quotation Number` ).
custom_e1edk02_segment( `004`, quotation_number ).
	
i_op_param( output, _, _, _, orders05_idoc_xml ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_quotation_number
	, [ without( quotation_number ), quotation_number( `` ) ]
	
	, get_order_number
	
	, get_comments
	
	, set_priority_attachment

] ).

%=======================================================================
i_rule( set_priority_attachment, [ check( set_imail_data( `body`, `do_not_process` ) ) ] ).
%=======================================================================

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

	, buyer_registration_number( `US-QUOTES` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11232646` ) ]    %TEST
	    , suppliers_code_for_buyer( `10769760` )                      %PROD
	]) ]
	
	, [ or([ 
	  [ test(test_flag), delivery_note_number( `11232646` ) ]    %TEST
	    , delivery_note_number( `10769760` )                      %PROD
	]) ]

	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, sender_name( `Department of Water and Power` )
	
	, custom_notification_address( `HNAGovernment@hilti.com` )
	
	, set( enable_duplicate_check )
	, set( quotation )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Customer Comments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_comments, [ 
%=======================================================================

	q0n(line), generic_line( [ `REFERENCE` ] )
	
	, q10( [ generic_line( [ [ `Control`, `Number` ] ] )
		, q(0,10,line), generic_line( [ [ `P`, `.`, `O`, `.`, `BOX`, `51111` ] ] )
	] )
	
	, generic_line( [ [ retab( [ 500 ] ), generic_item( [ customer_comments, s1 ] ) ] ] )
	, q0n( generic_line( [ [ retab( [ 500 ] ), append( customer_comments(s1), `~`, `` ) ] ] ) )
	
	, generic_line( [ or( [ `Buyer`, [ `Control`, `Number` ] ] ) ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_quotation_number, [ 
%=======================================================================

	q0n(line), generic_line( [ `REFERENCE` ] )
	
	, q(0,15,line), generic_horizontal_details( [ [ or( [ `Quotation`, `quote` ] ), q10( or( [ `Number`, `#` ] ) ) ], quotation_number, d ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER & DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	q(0,20,line)
	
	, generic_vertical_details( [ [ `SPO`, `NO`, `.` ], `No`, q(0,1), (start,10,10), order_number, s1 ] )
	
] ).