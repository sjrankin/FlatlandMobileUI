//
//  K-Means.swift
//  K-Means
//
//  Created by Stuart Rankin on 7/20/21. Adapted from Flatland View.
//

import Foundation

/// K-Means clustering. Algorithm adapted from _Classic Computer Science Problems in Swift_.
class KMeans<PointType: KMDataPoint>
{
    public  class Cluster
    {
        var Points: [PointType] = [PointType]()
        var Centroid: PointType!
        
        init(Centroid: PointType)
        {
            self.Centroid = Centroid
        }
    }
    
    private var Points: [PointType]!
    private var Clusters: [Cluster]!
    
    private var Centroids: [PointType]
    {
        return Clusters.map{$0.Centroid}
    }
    
    init(K: UInt, Points: [PointType])
    {
        self.Points = Points
        Clusters = [Cluster]()
        ZScoreNormalize()
        for _ in 0 ..< K
        {
            let RandomPoint = CreateRandomPoint()
            Clusters.append(Cluster(Centroid: RandomPoint))
        }
    }
    
    private func DimensionSlice(_ Index: Int) -> [Double]
    {
        return Points.map{$0.Dimensions[Index]}
    }
    
    private func ZScoreNormalize()
    {
        for Dim in 0 ..< Int(PointType.NumDimensions)
        {
            for (Index, ZScore) in DimensionSlice(Dim).ZScore.enumerated()
            {
                Points[Index].Dimensions[Dim] = ZScore
            }
        }
    }
    
    private func CreateRandomPoint() -> PointType
    {
        var RandDims = [Double]()
        for Dim in 0 ..< Int(PointType.NumDimensions)
        {
            let Values = DimensionSlice(Dim)
            let RandVal = Double.random(in: Values.min()! ... Values.max()!)
            RandDims.append(RandVal)
        }
        return PointType(Values: RandDims)
    }
    
    private func AssignClusters()
    {
        for Point in Points
        {
            var Lowest = Double.greatestFiniteMagnitude
            var ClosestCluster = Clusters.first!
            for (Index, Centroid) in Centroids.enumerated()
            {
                if Centroid.Distance(To: Point) < Lowest
                {
                    Lowest = Centroid.Distance(To: Point)
                    ClosestCluster = Clusters[Index]
                }
            }
            ClosestCluster.Points.append(Point)
        }
    }
    
    private func GenerateCentroids()
    {
        for Cluster in Clusters
        {
            var Means = [Double]()
            for Dim in 0 ..< Int(PointType.NumDimensions)
            {
                Means.append(Cluster.Points.map({$0.Dimensions[Dim]}).Mean)
            }
            Cluster.Centroid = PointType(Values: Means)
        }
    }
    
    public func Run(MaxIterations: UInt = 100) -> [Cluster]
    {
        for _ in 0 ..< MaxIterations
        {
            Clusters.forEach{$0.Points.removeAll()}
            AssignClusters()
            let LastCentroids = Centroids
            GenerateCentroids()
            if LastCentroids == Centroids
            {
                return Clusters
            }
        }
        return Clusters
    }
}
