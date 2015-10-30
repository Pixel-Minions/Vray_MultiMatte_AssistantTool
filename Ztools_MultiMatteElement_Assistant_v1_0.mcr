macroScript MultiMatteElement_Assistant 
	category:"Ztools"
	toolTip:"MultiMatteElement_Assistant"
	buttontext:"MultiMatteElement_Assistant"
	Icon:#("ZMA", 1)
(
	-- Ztool - Vray MultiMatteElement Assistant for 3ds Max
	--Created by Jose Alejandro Enriquez 
	-- version 1.0
	-- 26 / 01 / 2015

	--seleccionar objetos por nombre
	listName = ""
	elements = #()
	allObj = #()
	autoselect = $*
	elementName="Matte_"
	listenerInfoChecker = 0
	rule = ""
	removeElements = 0
	print elements.count
	--add items to the allobj array if the pass the filter
	fn filterElement  =
	(
		for i in autoselect do
		(
			y = i.name
			x = findString  y rule
			w = findString i.name "Target"
			if  x != undefined and superclassof i == GeometryClass and w == undefined then
			(
				append allObj i	
			)
			
			else if superclassof i == GeometryClass then
			(
				if listenerInfoChecker == 1 then
				(
					errorMessage = "Sorry, the item doesn't match the requirements: " + y
					print errorMessage
				)
			)		
			
			else
			(
				--errorMessage = "Item is not GeometryClass: " + y + ", Ignored"
				--print errorMessage
				--print i.name as string
			)
			
		)
	)

	--Crea el pase de acuerdo a elementName generado en nameCreation()
	fn elementCreation elementName =
	(
		re = maxOps.GetCurRenderElementMgr()
		pass = MultiMatteElement
		adpElementName = replace elementName (elementName.count) 1 ""
		
		re.addrenderelement (MultiMatteElement elementname:adpElementName)
	)


	--Filtra y crea una lista de acuerdo al nombre


	fn executeClassification =
	(
		for i in allObj do
		(
			
			global listName, elements
			objName = i.name 
			SplitName = filterstring objName rule
			listName = SplitName[1]	
			appendIfUnique elements listName
			indexObj = findItem elements listName		
			i.gbufferchannel = indexObj

		)	
	)

	--Crea nombres de pases, y agrega ID a los render elements

	fn nameCreation elements =
	(
		elementName = "Matte_"
		bufferCount = 0
		elementCount = 1
		elements.count
		idAsigned = 0
		
		for i in elements do
		(
			 i as string
			elementName += i + "_"
			bufferCount += 1
			secondVal = bufferCount - 2
			if mod bufferCount  3 ==  0  then
			(
				elementCreation(elementName)
				
				re=maxOps.GetCurRenderElementMgr()
				x = re.numrenderelements()
				w = x - 1
				k = re.GetRenderElement w
				elementCount += 1			
				k.R_gbufID = bufferCount - 2
				k.G_gbufID = bufferCount - 1
				k.B_gbufID = bufferCount
				
				idAsigned += 3			
				elementName = "Matte_"
				
			)
		
			
			else if mod secondVal 3 == 0 and elements.count - idAsigned == 2  then
			(						
				x = elements.count - idAsigned	
				y = x as string + " este es"
				print y
				elementCreation(elementName)
				re=maxOps.GetCurRenderElementMgr()
				x = re.numrenderelements()			
				w = x - 1
				k = re.GetRenderElement w
				print k as string
				elementCount += 1			
				k.R_gbufID = bufferCount - 1
				k.G_gbufID = bufferCount 
				k.B_gbufID = 0
				k.B_gbufIDOn = False
				
			)
			else if elements.count - idAsigned == 1 then
			(			
				elementCreation(elementName)
				re=maxOps.GetCurRenderElementMgr()
				x = re.numrenderelements()
				w = x - 1
				k = re.GetRenderElement w
				elementCount += 1			
				k.R_gbufID = bufferCount 
				k.G_gbufID = 0
				k.G_gbufIDOn = False
				k.B_gbufID = 0
				k.B_gbufIDOn = False
			)
			
			else 
			(
				
			)

		)
		
	)

	rollout MME "Ztool - Vray MultiMatteElement Assistant " width: 300 height:120
	(
		global listenerInfoChecker, removeElements
		checkbox listenerInfo "Print Log to MaxScript Listener" checked:False
		on listenerInfo changed state do
		if state == True then
		(
			listenerInfoChecker = 1
		)
		else
		(
			listenerInfoChecker = 0
		)
		
		checkbox deleteOld "Delete current Render Elements (All of them)"
		on deleteOld changed state do
			if state == True then
			(
				removeElements = 1
			)
			else
			(
				removeElements = 0
			)
		
		group "By Name"
		(
			edittext ruleBox "Name's rule(ex: - . _)" fieldwidth:50 labelOnTop: False
			on ruleBox entered txt do
			(
				if txt != "" then
				(
					global rule
					rule = txt as string
				)
				
				else
				(
					messagebox = "Missing Rule" 
				)
			)
			
			
			button btn1 "Execute" width: 100 height:25
		)
		on btn1 pressed do
		(
			if rule == ""then
			(
				messagebox "Missing Rule"
			)
			else
			(
				
				if removeElements == 1 then
				(
					
					re=maxOps.GetCurRenderElementMgr()
					re.RemoveAllRenderElements()					
				)
				else
				(
				)
				
				filterElement()
				executeClassification()
				nameCreation(elements)			
				DestroyDialog MME
				if renderSceneDialog.isOpen() then
				(
					renderSceneDialog.close()
					renderSceneDialog.open()
				)
				else
				(
				)
			)
			
		)
	)
	createDialog MME








)
