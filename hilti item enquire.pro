%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  HILTI ITEM ENQUIRE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hilti_item_enquire, `05 March 2015` ).

%=======================================================================
i_final_rule( [ set( enquire_on_line_items ) ]) :- chained_to(`azmeel`).
%=======================================================================


%=======================================================================
i_final_rule( [
%=======================================================================
	or( [ [ with( _, line_item, Item )
			, check( string_to_lower( Item, Item_L ) )
			, check( Item_L = `missing` )
		]
		
		, [ check( q_sys_member( Var, [ line_descr, line_quantity, line_unit_amount ] ) )
			, with( LID, Var, _ )
			, peek_fails( with( LID, line_item, _ ) )	
		]
	] )
	
	, set( enquire_on_line_items )
	, trace( [ `Will enquire` ] )
	
] )
:-
	result( _, invoice, agent_code_3, Agent_3 ),
	allowed_agents( Agent_3 ),
	( i_mail(to, `orders.test@ecx.adaptris.com` ); i_mail(to, `adam.bateman@openecx.co.uk` ) )
.	

% allowed_agents( `4600` ).
% allowed_agents( `4400` ).	


%=======================================================================
i_analyse_line_fields_first( LID )
%----------------------------------------------------------------------
:-	grammar_set( enquire_on_line_items ), i_analyse_line_items( LID ).
%=======================================================================

%=======================================================================
i_analyse_line_items( LID )
%----------------------------------------------------------------------
:-
%=======================================================================

	trace( `Analysing` ),
	sys_string_number( Line_No, LID ),
	
	( result( _, LID, line_descr, Descr )
		->	true
		;	Descr = ``
	),
	
	( result( _, LID, line_quantity, Qty )
		->	true
		;	Qty = ``
	),

	( result( _, LID, line_quantity_uom_code, Input_UOM )
		->	true
		;	Input_UOM = ``
	),

	( result( _, LID, line_item, Item )
		->	true
		;	Item = ``
	),
	
	( result( _, LID, line_item_for_buyer, BItem )
		->	true
		;	BItem = ``
	),
	
	strcat_list( [ `No: `, Line_No,
			`^^Description: `, Descr,
			`^^Quantity: missing`,
			`^^UOM: missing`,
			`^^Hilti Code:  missing`,
			`^^Customer Code: missing`
		], Question
	),
	
	strcat_list( [ `Quantity: `, Qty, `^^UOM: `, Input_UOM, `^^Hilti Code: `, Item, `^^Customer Code: `, BItem ], Answer ),
	
	trace( Question ), trace( Answer ),

	rule( enquire, [ Question ], Answer, Raw, OK, [ ], SF, G, G ),

	( OK = `answered`

		->	Raw = data( Enquire_answer, _ ),

			sys_string_split( Enquire_answer, `:^`, [ _, QS, _, UOMS, _, IS, _, BIS ] ),

			sys_retractall( result( _, LID, line_quantity, _ ) ),

			sys_retractall( result( _, LID, line_quantity_uom_code, _ ) ),
		
			sys_retractall( result( _, LID, line_item, _ ) ),
		
			sys_retractall( result( _, LID, line_item_for_buyer, _ ) ),
		
			sys_string_trim( QS, QST ),

			sys_string_trim( UOMS, UOMST ),

			sys_string_trim( IS, IST ),

			sys_string_trim( BIS, BIST ),

			assertz_derived_data( LID, line_quantity, QST, i_enquired_on_line_item ),

			assertz_derived_data( LID, line_quantity_uom_code, UOMST, i_enquired_on_line_item ),

			assertz_derived_data( LID, line_item, IST, i_enquired_on_line_item ),

			assertz_derived_data( LID, line_item_for_buyer, BIST, i_enquired_on_line_item )

		;	true
		
	),
	
	asserta_if_missing( grammar_set( need_confirmation ) ),
	
	!
.

%=======================================================================
i_analyse_line_fields_last( LID )
%----------------------------------------------------------------------
:-	i_analyse_line_item_confirmation( LID ).
%=======================================================================
%=======================================================================
i_analyse_line_item_confirmation( LID )
%----------------------------------------------------------------------
:-
%=======================================================================

	LID = 1, 

	grammar_set( need_confirmation ),

	rule( enquire, [ `Form Type: Hilti` ], default_var, _, _, [ ], _, _, _ ),
	rule( enquire, [ `Are you happy with the data entered?` ], default_var, Raw, OK, [ ], SF, G, G ),
	
	( OK = `answered`
		->	trace( `(enq) Answers have been confirmed` ),
			default_var( `Done` )
		
		;	true
		
	), !
.
