OOF.Microstructure.Create_From_ImageFile(filename='../swoops.png', microstructure_name='swoops.png', height=automatic, width=automatic)
OOF.Windows.Graphics.New()
OOF.Graphics_1.Layer.Select(n=0)
OOF.Skeleton.New(name='skeleton', microstructure='swoops.png', x_elements=2, y_elements=2, skeleton_geometry=QuadSkeleton(left_right_periodicity=False,top_bottom_periodicity=False))
OOF.Skeleton.Modify(skeleton='swoops.png:skeleton', modifier=Refine(targets=CheckHomogeneity(threshold=0.9),divider=Bisection(minlength=0),rules='Quick',alpha=0.8))
OOF.Skeleton.Modify(skeleton='swoops.png:skeleton', modifier=Refine(targets=CheckHomogeneity(threshold=0.9),divider=Bisection(minlength=0),rules='Quick',alpha=0.8))
OOF.Skeleton.Modify(skeleton='swoops.png:skeleton', modifier=Refine(targets=CheckHomogeneity(threshold=0.9),divider=Bisection(minlength=0),rules='Quick',alpha=0.8))
OOF.Skeleton.Modify(skeleton='swoops.png:skeleton', modifier=Refine(targets=CheckHomogeneity(threshold=0.9),divider=Bisection(minlength=0),rules='Quick',alpha=0.8))
OOF.Skeleton.Modify(skeleton='swoops.png:skeleton', modifier=Refine(targets=CheckHomogeneity(threshold=0.9),divider=TransitionPoints(minlength=0.1),rules='Quick',alpha=0.8))
OOF.Skeleton.Modify(skeleton='swoops.png:skeleton', modifier=Rationalize(targets=AllElements(),criterion=AverageEnergy(alpha=0.8),method=SpecificRationalization(rationalizers=[RemoveShortSide(ratio=5.0), QuadSplit(angle=150), RemoveBadTriangle(acute_angle=15,obtuse_angle=150)]),iterations=2))
OOF.Skeleton.PinNodes.Pin_Internal_Boundary_Nodes(skeleton='swoops.png:skeleton')
OOF.Skeleton.Modify(skeleton='swoops.png:skeleton', modifier=Smooth(targets=AllNodes(),criterion=AverageEnergy(alpha=0.3),T=0.0,iteration=FixedIteration(iterations=5)))
OOF.Skeleton.PinNodes.Undo(skeleton='swoops.png:skeleton')
OOF.Skeleton.Delete(skeleton='swoops.png:skeleton')
OOF.PixelGroup.AutoGroup(grouper=ColorGrouper(image='swoops.png:swoops.png',sigma0=0.002), delta=2, gamma=4, minsize=100, contiguous=True, name_template='group_%n', clear=True)
OOF.Skeleton.New(name='skeleton', microstructure='swoops.png', x_elements=2, y_elements=2, skeleton_geometry=QuadSkeleton(left_right_periodicity=False,top_bottom_periodicity=False))
OOF.Skeleton.Modify(skeleton='swoops.png:skeleton', modifier=Refine(targets=CheckHomogeneity(threshold=0.9),divider=Bisection(minlength=0),rules='Quick',alpha=0.8))
OOF.Skeleton.Modify(skeleton='swoops.png:skeleton', modifier=Refine(targets=CheckHomogeneity(threshold=0.9),divider=Bisection(minlength=0),rules='Quick',alpha=0.8))
OOF.Skeleton.Modify(skeleton='swoops.png:skeleton', modifier=Refine(targets=CheckHomogeneity(threshold=0.9),divider=Bisection(minlength=0),rules='Quick',alpha=0.8))
OOF.Skeleton.Modify(skeleton='swoops.png:skeleton', modifier=Refine(targets=CheckHomogeneity(threshold=0.9),divider=Bisection(minlength=0),rules='Quick',alpha=0.8))
OOF.Skeleton.Modify(skeleton='swoops.png:skeleton', modifier=Refine(targets=CheckHomogeneity(threshold=0.9),divider=TransitionPoints(minlength=0.1),rules='Quick',alpha=0.8))
OOF.Skeleton.Modify(skeleton='swoops.png:skeleton', modifier=Rationalize(targets=AllElements(),criterion=AverageEnergy(alpha=0.8),method=SpecificRationalization(rationalizers=[RemoveShortSide(ratio=5.0), QuadSplit(angle=150), RemoveBadTriangle(acute_angle=15,obtuse_angle=150)]),iterations=2))
OOF.Skeleton.PinNodes.Pin_Internal_Boundary_Nodes(skeleton='swoops.png:skeleton')
OOF.Skeleton.Modify(skeleton='swoops.png:skeleton', modifier=Smooth(targets=AllNodes(),criterion=AverageEnergy(alpha=0.3),T=0.0,iteration=FixedIteration(iterations=5)))
OOF.Skeleton.PinNodes.Undo(skeleton='swoops.png:skeleton')
OOF.Material.New(name='grains', material_type='bulk')
OOF.Graphics_1.Toolbox.Pixel_Info.Query(x=260, y=170)
OOF.PixelSelection.Select_Group(microstructure='swoops.png', group='group_1')
OOF.PixelSelection.Invert(microstructure='swoops.png')
OOF.Material.Assign(material='grains', microstructure='swoops.png', pixels=selection)
OOF.Material.New(name='matrix', material_type='bulk')
OOF.PixelSelection.Invert(microstructure='swoops.png')
OOF.Material.Assign(material='matrix', microstructure='swoops.png', pixels=selection)
OOF.Property.Parametrize.Thermal.Conductivity.Isotropic(kappa=1)
OOF.Material.Add_property(name='matrix', property='Thermal:Conductivity:Isotropic')
OOF.Property.Copy(property='Thermal:Conductivity:Isotropic', new_name='higher')
OOF.Property.Parametrize.Thermal.Conductivity.Isotropic.higher(kappa=5)
OOF.Material.Add_property(name='grains', property='Thermal:Conductivity:Isotropic:higher')
OOF.Material.Remove_property(name='grains', property='Thermal:Conductivity:Isotropic:higher')
OOF.Material.Add_property(name='grains', property='Thermal:Conductivity:Isotropic:higher')
OOF.Material.Remove_property(name='matrix', property='Thermal:Conductivity:Isotropic')
OOF.Material.Add_property(name='matrix', property='Thermal:Conductivity:Isotropic:higher')
OOF.Mesh.New(name='mesh', skeleton='swoops.png:skeleton', element_types=['D2_3', 'T3_6', 'Q4_8'])
OOF.Subproblem.Field.Define(subproblem='swoops.png:skeleton:mesh:default', field=Temperature)
OOF.Subproblem.Field.Activate(subproblem='swoops.png:skeleton:mesh:default', field=Temperature)
OOF.Mesh.Field.In_Plane(mesh='swoops.png:skeleton:mesh', field=Temperature)
OOF.Subproblem.Equation.Activate(subproblem='swoops.png:skeleton:mesh:default', equation=Heat_Eqn)
OOF.Mesh.Boundary_Conditions.New(name='bc', mesh='swoops.png:skeleton:mesh', condition=DirichletBC(field=Temperature,field_component='',equation=Heat_Eqn,eqn_component='',profile=ConstantProfile(value=0),boundary='left'))
OOF.Mesh.Boundary_Conditions.New(name='bc<2>', mesh='swoops.png:skeleton:mesh', condition=DirichletBC(field=Temperature,field_component='',equation=Heat_Eqn,eqn_component='',profile=ConstantProfile(value=1),boundary='right'))
OOF.Subproblem.Set_Solver(subproblem='swoops.png:skeleton:mesh:default', solver_mode=BasicSolverMode(time_stepper=BasicStaticDriver(),matrix_method=BasicIterative(tolerance=1e-13,max_iterations=1000)))
OOF.Mesh.Solve(mesh='swoops.png:skeleton:mesh', endtime=0.0)
OOF.Graphics_1.Layer.New(category='Mesh', what='swoops.png:skeleton:mesh', how=FilledContourDisplay(when=latest,what=getOutput('Field:Component',component='',field=Temperature),where=getOutput('original'),min=automatic,max=automatic,levels=11,nbins=5,colormap=ThermalMap()))
OOF.Graphics_1.Toolbox.Pixel_Info.Clear()
OOF.Graphics_1.Settings.Zoom.Fill_Window()
OOF.Graphics_1.Layer.Edit(n=1, category='Mesh', what='swoops.png:skeleton:mesh', how=FilledContourDisplay(when=latest,what=getOutput('Field:Component',component='',field=Temperature),where=getOutput('original'),min=automatic,max=automatic,levels=21,nbins=5,colormap=ThermalMap()))
OOF.Graphics_1.Toolbox.Mesh_Info.QueryElement(position=Point(51.23071648954402,195.7576276996914))
OOF.Graphics_1.Toolbox.Mesh_Info.QueryElement(position=Point(455.9972574562907,218.47411724374354))
OOF.Graphics_1.Settings.Zoom.Fill_Window()
OOF.Graphics_1.Toolbox.Mesh_Info.QueryElement(position=Point(138.1832016406297,205.85360998853974))
OOF.Graphics_1.Layer.Edit(n=1, category='Mesh', what='swoops.png:skeleton:mesh', how=FilledContourDisplay(when=latest,what=getOutput('Field:Component',component='',field=Temperature),where=getOutput('original'),min=automatic,max=automatic,levels=21,nbins=5,colormap=SpectralMap(saturation=0.559633,value=0.513761)))
OOF.Graphics_1.Layer.Edit(n=1, category='Mesh', what='swoops.png:skeleton:mesh', how=FilledContourDisplay(when=latest,what=getOutput('Field:Component',component='',field=Temperature),where=getOutput('original'),min=automatic,max=automatic,levels=21,nbins=5,colormap=SpectralMap(saturation=1,value=0.513761)))
OOF.Graphics_1.Layer.Edit(n=1, category='Mesh', what='swoops.png:skeleton:mesh', how=FilledContourDisplay(when=latest,what=getOutput('Field:Component',component='',field=Temperature),where=getOutput('original'),min=automatic,max=automatic,levels=21,nbins=5,colormap=SpectralMap(saturation=1,value=1)))
OOF.Graphics_1.Layer.Edit(n=1, category='Mesh', what='swoops.png:skeleton:mesh', how=FilledContourDisplay(when=latest,what=getOutput('Field:Component',component='',field=Temperature),where=getOutput('original'),min=automatic,max=automatic,levels=21,nbins=5,colormap=TequilaSunrise()))
OOF.Graphics_1.Layer.Edit(n=1, category='Mesh', what='swoops.png:skeleton:mesh', how=FilledContourDisplay(when=latest,what=getOutput('Field:Component',component='',field=Temperature),where=getOutput('original'),min=automatic,max=automatic,levels=21,nbins=5,colormap=GistEarth()))
OOF.Graphics_1.Layer.Edit(n=1, category='Mesh', what='swoops.png:skeleton:mesh', how=FilledContourDisplay(when=latest,what=getOutput('Field:Component',component='',field=Temperature),where=getOutput('original'),min=automatic,max=automatic,levels=21,nbins=5,colormap=HSVMap(saturation=1,value=1,phase_shift=180)))
OOF.Graphics_1.Layer.Edit(n=1, category='Mesh', what='swoops.png:skeleton:mesh', how=FilledContourDisplay(when=latest,what=getOutput('Field:Component',component='',field=Temperature),where=getOutput('original'),min=automatic,max=automatic,levels=21,nbins=5,colormap=HSVMap(saturation=0.415254,value=1,phase_shift=180)))
OOF.Property.Parametrize.Thermal.Conductivity.Isotropic.higher(kappa=3)
OOF.Mesh.Solve(mesh='swoops.png:skeleton:mesh', endtime=0.0)
OOF.Property.Parametrize.Thermal.Conductivity.Isotropic.higher(kappa=10)
OOF.Mesh.Solve(mesh='swoops.png:skeleton:mesh', endtime=0.0)
OOF.Graphics_1.Layer.Edit(n=1, category='Mesh', what='swoops.png:skeleton:mesh', how=FilledContourDisplay(when=latest,what=getOutput('Field:Component',component='',field=Temperature),where=getOutput('original'),min=automatic,max=automatic,levels=21,nbins=5,colormap=SpectralMap(saturation=1,value=1)))
OOF.Mesh.Solve(mesh='swoops.png:skeleton:mesh', endtime=0.0)
OOF.Graphics_1.Layer.Edit(n=1, category='Mesh', what='swoops.png:skeleton:mesh', how=FilledContourDisplay(when=latest,what=getOutput('Field:Component',component='',field=Temperature),where=getOutput('original'),min=automatic,max=automatic,levels=21,nbins=5,colormap=ThermalMap()))
OOF.Windows.Graphics.New()
OOF.Graphics_2.Layer.Select(n=5)
OOF.Graphics_2.File.Close()
OOF.Graphics_1.Settings.Time(time=0.0)
OOF.Graphics_1.Toolbox.Select_Element.Single_Element(skeleton='swoops.png:skeleton', points=[Point(122.19120574220396,348.28729115145666)], shift=False, ctrl=False)
OOF.Graphics_1.Toolbox.Select_Element.Single_Element(skeleton='swoops.png:skeleton', points=[Point(207.39706858073464,411.87375595633034)], shift=True, ctrl=False)
OOF.Graphics_1.Toolbox.Select_Element.Single_Element(skeleton='swoops.png:skeleton', points=[Point(258.26624042463357,397.88473369925816)], shift=True, ctrl=False)
OOF.Graphics_1.Toolbox.Select_Element.Single_Element(skeleton='swoops.png:skeleton', points=[Point(259.53796972073104,380.0805235538935)], shift=True, ctrl=False)
OOF.Graphics_1.Toolbox.Select_Element.Single_Element(skeleton='swoops.png:skeleton', points=[Point(254.45105253634117,326.6678931177996)], shift=True, ctrl=False)
OOF.Graphics_1.Toolbox.Select_Element.Clear(skeleton='swoops.png:skeleton')
OOF.Graphics_1.Layer.Select(n=6)
OOF.Graphics_1.Layer.Select(n=1)
OOF.Graphics_1.Layer.Select(n=0)
OOF.Graphics_1.Layer.Select(n=5)
OOF.Graphics_1.Layer.Hide(n=5)
OOF.Graphics_1.Layer.Hide(n=1)
OOF.Graphics_1.Layer.Select(n=1)
OOF.Graphics_1.Layer.Show(n=1)
OOF.Graphics_1.Layer.Show(n=5)
OOF.Graphics_1.Layer.Select(n=5)
OOF.Graphics_1.Layer.Hide(n=0)
OOF.Graphics_1.Layer.Select(n=0)
OOF.Graphics_1.Layer.Show(n=0)
OOF.Graphics_1.Layer.Hide(n=0)
OOF.Graphics_1.Layer.Show(n=0)
OOF.Graphics_1.Layer.Hide(n=0)
OOF.Graphics_1.Layer.Show(n=0)
OOF.Graphics_1.Layer.Hide(n=5)
OOF.Graphics_1.Layer.Select(n=5)
OOF.Graphics_1.Layer.Select(n=1)
OOF.Graphics_1.Layer.New(category='Mesh', what='swoops.png:skeleton:mesh', how=FilledContourDisplay(when=latest,what=getOutput('Flux:Invariant',invariant=Magnitude(),flux=Heat_Flux),where=getOutput('original'),min=automatic,max=automatic,levels=11,nbins=5,colormap=GrayMap()))
OOF.Graphics_1.Layer.Lower.One_Level(n=2)
OOF.Graphics_1.Layer.Delete(n=1)
OOF.Graphics_1.Layer.Select(n=5)